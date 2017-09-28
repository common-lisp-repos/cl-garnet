/* Lisp parsing and input streams.
   Copyright (C) 1985 Richard M. Stallman.

This file is part of GNU Emacs.

GNU Emacs is distributed in the hope that it will be useful,
but without any warranty.  No author or distributor
accepts responsibility to anyone for the consequences of using it
or for whether it serves any particular purpose or works at all,
unless he says so in writing.

Everyone is granted permission to copy, modify and redistribute
GNU Emacs, but only under the conditions described in the
document "GNU Emacs copying permission notice".   An exact copy
of the document is supposed to have been given to you along with
GNU Emacs so that you can know how you may redistribute it all.
It should be in a file named COPYING.  Among other things, the
copyright notice and this notice must be preserved on all copies.  */


#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/file.h>
#undef NULL
#include "config.h"
#include "lisp.h"

#ifndef standalone
#include "paths.h"
#include "buffer.h"
#endif

Lisp_Object Qread_char, Qget_file_char, Qstandard_input;
Lisp_Object Qvariable_documentation, Vvalues, Vstandard_input;

/* Search path for files to be loaded. */
static Lisp_Object Vload_path;

/* File for get_file_char to read from.  Use by load */
static FILE *instream;

/* When nonzero, read conses in pure space */
static int read_pure;

/* For use within read-from-string (this reader is non-reentrant!!) */
static int read_from_string_index;
static int read_from_string_limit;


/* Handle unreading and rereading of characters.  Write READCHAR to
   read a character, UNREAD(c) to unread c to be read again. */
static int unrch;

static int readchar (Lisp_Object readcharfun) {
  Lisp_Object tem;
  struct buffer_text *inbuffer;
  int c,
    mpos;
  if (unrch >= 0) {
    c = unrch;
    unrch = -1;
    return c;
  }
  if (XTYPE (readcharfun) == Lisp_Buffer) {
    if (XBUFFER (readcharfun) == bf_cur) {
      inbuffer = &bf_text;
    } else {
      inbuffer = &XBUFFER (readcharfun)->text;
    }
    if (inbuffer->dotloc >
	inbuffer->size1 + inbuffer->size2 - inbuffer->tail_clip) {
      return -1;
    }
    c = *(unsigned char *) &(inbuffer->dotloc > inbuffer->size1 ?
			     inbuffer->p2 :
			     inbuffer->p1)[inbuffer->dotloc];
    inbuffer->dotloc++;
    return c;
  }
  if (XTYPE (readcharfun) == Lisp_Marker) {
    if (XMARKER (readcharfun)->buffer == bf_cur) {
      inbuffer = &bf_text;
    } else {
      inbuffer = &XMARKER (readcharfun)->buffer->text;
    }
    mpos = marker_position (readcharfun);
    if (mpos >
	inbuffer->size1 + inbuffer->size2 - inbuffer->tail_clip)
      return -1;
    c = *(unsigned char *) &(mpos > inbuffer->size1 ? inbuffer->p2 : inbuffer->p1)[mpos];
    if (mpos != inbuffer->size1 + 1)
      XMARKER (readcharfun)->bufpos++;
    else
      Fset_marker (readcharfun, make_number (mpos + 1),
		   Fmarker_buffer (readcharfun));
    return c;
  }
  if (EQ (readcharfun, Qget_file_char)) {
    return getc (instream);
  }
  if (XTYPE (readcharfun) == Lisp_String) {
    return (read_from_string_index < read_from_string_limit) ?
      XSTRING (readcharfun)->data[read_from_string_index++] : -1;
  }
  tem = Fapply (readcharfun, Qnil);
  if (NULL (tem)) {
    return -1;
  }
  return XINT (tem);
}

#define READCHAR readchar(readcharfun)
#define UNREAD(c) (unrch = c)

static Lisp_Object read0 (),
  read1 (),
  read_list (),
  read_vector ();

/* get a character from the tty */
DEFUN ("read-char", Fread_char, Sread_char, 0, 0, 0,
  "Read a character from the command input (keyboard or macro).\n\
It is returned as a number.")
  () {
  register Lisp_Object val;
  XSETTYPE (val, Lisp_Int);
  XSETINT (val, getchar ());
  return val;
}

DEFUN ("get-file-char", Fget_file_char, Sget_file_char, 0, 0, 0,
  "Don't use this yourself.")
  () {
  Lisp_Object val;
  XSETTYPE (val, Lisp_Int);
  XSETINT (val, getc (instream));
  return val;
}

void readevalloop ();
Lisp_Object closefile ();

DEFUN ("load", Fload, Sload, 1, 3, "sLoad file: ",
  "Execute a file of Lisp code named FILE.\n\
First tries FILE with .elc appended, then tries with .el,\n\
 then tries FILE unmodified.  Searches directories in  load-path.\n\
If optional second arg MISSING-OK is non-nil,\n\
 report no error if FILE doesn't exist.\n\
Print messages at start and end of loading unless\n\
 optional third arg NOMESSAGE is non-nil.\n\
Return t if file exists.")
  (Lisp_Object str, Lisp_Object missing_ok, Lisp_Objectnomessage) {
  FILE *stream;
  int fd;
  Lisp_Object lispstream;
  int count = specpdl_ptr - specpdl;
  struct gcpro gcpro1;
  CHECK_STRING (str, 0);
  if (!XSTRING (str)->size) {
    error ("Empty file name");
  }
  str = Fsubstitute_in_file_name (str);
  fd = openp (Vload_path, str, ".elc", 0, 0);
  if (fd < 0) {
    fd = openp (Vload_path, str, ".el", 0, 0);
  }
  if (fd < 0) {
    fd = openp (Vload_path, str, "", 0, 0);
  }
  if (fd < 0) {
    if (NULL (missing_ok)) {
      Fsignal (Qfile_error, Fcons (build_string ("Cannot open load file"),
				   Fcons (str, Qnil)));
    }
  } else {
    return Qnil;
  }
  stream = fdopen (fd, "r");
  XSETTYPE (lispstream, Lisp_Internal_Stream);
  XSETINT (lispstream, (int) stream);
  if (NULL (nomessage)) {
    message ("Loading %s...", XSTRING (str)->data);
  }
  GCPRO1 (str);
  record_unwind_protect (closefile, lispstream);
  readevalloop (Qget_file_char, stream, Feval, 0);
  unbind_to (count);
  UNGCPRO;
  if (NULL (nomessage)) {
    message ("Loading %s...done", XSTRING (str)->data);
  }
  return Qt;
}

/* exec_only nonzero means don't open the files, just look for one
   that is executable; returns 1 on success, having stored a string
   into *storeptr */
int openp (Lisp_Object path, Lisp_Object str, char* suffix,
	   Lisp_Object storeptr, int exec_only) {
  int fd;
  int fn_size = 100;
  char buf[100];
  char *fn = buf;
  int absolute = 0;
  int want_size;
  Lisp_Object file;
  struct stat st;
  if (storeptr) {
    *storeptr = Qnil;
  }
  if (*XSTRING (str)->data == '~' || *XSTRING (str)->data == '/') {
    absolute = 1;
  }
  for (; !NULL (path); path = Fcdr (path)) {
    file = Fexpand_file_name (str, Fcar (path));
    want_size = strlen (suffix) + XSTRING (file)->size + 1;
    if (fn_size < want_size) {
      fn = (char *) alloca (fn_size = 100 + want_size);
    }
    strncpy (fn, XSTRING (file)->data, XSTRING (file)->size);
    fn[XSTRING (file)->size] = 0;
    strcat (fn, suffix);
    if (exec_only) {
      if (!access (fn, X_OK) && stat (fn, &st) >= 0
	  && (st.st_mode & S_IFMT) != S_IFDIR) {
	if (storeptr) {
	  *storeptr = build_string (fn);
	}
	return 1;
      }
    } else {
      fd = open (fn, 0, 0);
      if (fd >= 0) {
	if (storeptr) {
	  *storeptr = build_string (fn);
	}
	return fd;
      }
    }
    if (absolute) {
      return -1;
    }
  }
  return -1;
}

/* Used as unwind-protect function in load */
Lisp_Object closefile (Lisp_Object stream) {
  fclose ((FILE *) XSTRING (stream));
  return Qnil;
}

/* Used as unwind-protect function in readevalloop */
Lisp_Object unreadpure () {
  read_pure = 0;
  return Qnil;
}

void readevalloop (Lisp_Object readcharfun, FILE stream, Lisp_Object evalfun,
		   int printflag) {
  int c;
  Lisp_Object val;
  int xunrch;
  int count = specpdl_ptr - specpdl;
  specbind (Qstandard_input, readcharfun);
  unrch = -1;
  while (1) {
    instream = stream;
    c = READCHAR;
    if (c == ';') {
      while ((c = READCHAR) != '\n' && c != -1);
      continue;
    }
    if (c < 0) {
      break;
    }
    if (c == ' ' || c == '\t' || c == '\n' || c == '\f') {
      continue;
    }
    if (!NULL (Vpurify_flag) && c == '(') {
      record_unwind_protect (unreadpure, Qnil);
      val = read_list (-1, readcharfun);
      unbind_to (count + 1);
    } else {
      UNREAD (c);
      val = read0 (readcharfun);
    }
    xunrch = unrch;
    unrch = -1;
    val = evalfun (val);
    if (printflag) {
      Vvalues = Fcons (val, Vvalues);
      if (EQ (Vstandard_output, Qt)) {
	Fprin1 (val, Qnil);
      } else {
	Fprint (val, Qnil);
      }
    }
    unrch = xunrch;
  }
  unbind_to (count);
}

DEFUN ("eval-current-buffer", Feval_current_buffer, Seval_current_buffer, 0, 1, "",
  "Execute the current buffer as Lisp code.\n\
Programs can pass argument PRINTFLAG which controls printing of output:\n\
nil means discard it; anything else is stream for print.")
  (Lisp_Object printflag) {
  int count = specpdl_ptr - specpdl;
  Lisp_Object tem;
  if (NULL (printflag)) {
    tem = Qsymbolp;
  } else {
    tem = printflag;
  }
  specbind (Qstandard_output, tem);
  record_unwind_protect (save_excursion_restore, save_excursion_save ());
  SetDot (FirstCharacter);
  readevalloop (Fcurrent_buffer (), 0, Feval, !NULL (printflag));
  unbind_to (count);
  return Qnil;
}

DEFUN ("eval-region", Feval_region, Seval_region, 2, 3, "r",
  "Execute the region as Lisp code.\n\
When called from programs, expects two arguments,\n\
giving starting and ending indices in the current buffer\n\
of the text to be executed.\n\
Programs can pass third argument PRINTFLAG which controls printing of output:\n\
nil means discard it; anything else is stream for print.")
  (Lisp_Object b, Lisp_Object e, Lisp_Object printflag) {
  int count = specpdl_ptr - specpdl;
  Lisp_Object tem;
  if (NULL (printflag)) {
    tem = Qsymbolp;
  } else {
    tem = printflag;
  }
  specbind (Qstandard_output, tem);
  if (NULL (printflag)) {
    record_unwind_protect (save_excursion_restore, save_excursion_save ());
  }
  record_unwind_protect (save_restriction_restore, save_restriction_save ());
  SetDot (XINT (b));
  Fnarrow_to_region (make_number (FirstCharacter), e);
  readevalloop (Fcurrent_buffer (), 0, Feval, !NULL (printflag));
  unbind_to (count);
  return Qnil;
}

DEFUN ("read", Fread, Sread, 0, 1, 0,
  "Read one Lisp expression as text from STREAM, return as Lisp object.\n\
If STREAM is nil, use the value of standard-input (which see).\n\
STREAM or standard-input may be:\n\
 a buffer (read from dot and advance it)\n\
 a marker (read from where it points and advance it)\n\
 a function (call it with no arguments for each character)\n\
 a string (takes text from string, starting at the beginning)\n\
 t (read text line using minibuffer and use it).")
  (Lisp_Object readcharfun) {
  Lisp_Object val;
  extern Lisp_Object Fread_minibuffer ();
  unrch = -1;	/* Allow buffering-back only within a read. */
  if (NULL (readcharfun)) {
    readcharfun = Vstandard_input;
  }
  if (EQ (readcharfun, Qt)) {
    readcharfun = Qread_char;
  }
  if (EQ (readcharfun, Qread_char)) {
    return Fread_minibuffer (build_string ("Lisp expression: "), Qnil);
  }
  if (XTYPE (readcharfun) == Lisp_String) {
    return Fcar (Fread_from_string (readcharfun, Qnil, Qnil));
  }
  return read0 (readcharfun);
}

DEFUN ("read-from-string", Fread_from_string, Sread_from_string, 1, 3, 0,
  "Read one Lisp expression which is represented as text by STRING.\n\
Returns a cons: (OBJECT-READ . FINAL-STRING-INDEX).\n\
START and END optionally delimit a substring of STRING from which to read;\n\
 they default to 0 and (string-length STRING) respectively.")
  (Lisp_Object string, Lisp_Object start, Lisp_Object end) {
  int startval, endval;
  Lisp_Object tem;
  CHECK_STRING (string,0);
  if (NULL (end)) {
    endval = XSTRING (string)->size;
  } else { CHECK_NUMBER (end,2);
    endval = XINT (end);
    if (endval < 0 || endval > XSTRING (string)->size) {
      Fsignal (Qargs_out_of_range, Fcons (string, Fcons (end, Qnil)));
    }
  }
  if (NULL (start)) {
    startval = 0;
  } else { CHECK_NUMBER (start,1);
    startval = XINT (start);
    if (startval < 0 || startval > endval) {
      Fsignal (Qargs_out_of_range, Fcons (string, Fcons (start, Qnil)));
    }
  }
  read_from_string_index = startval;
  read_from_string_limit = endval;
  unrch = -1;	/* Allow buffering-back only within a read. */
  tem = read0 (string);
  return Fcons (tem, make_number (read_from_string_index));
}

/* Use this for recursive reads, in contexts where internal tokens are
   not allowed. */
static Lisp_Object read0 (Lisp_Object readcharfun) {
  Lisp_Object val;
  char c;
  val = read1 (readcharfun);
  if (XTYPE (val) == Lisp_Internal) {
      c = XINT (val);
      Fsignal (Qinvalid_read_syntax, Fcons (make_string (&c, 1), Qnil));
    }
  return val;
}

static int read_buffer_size;
static char *read_buffer;

static Lisp_Object read1 (Lisp_Object readcharfun) {
  int c;
 retry:
  c = READCHAR;
  if (c < 0) {
    Fsignal (Qend_of_file, Qnil);
  }
  switch (c) {
  case '(':
    return read_list (0, readcharfun);
  case '[':
    return read_vector (readcharfun);
  case ')':
  case ']':
  case '.': {
    Lisp_Object val;
    XSETTYPE (val, Lisp_Internal);
    XSETINT (val, c);
    return val;
  }
  case '#':
    Fsignal (Qinvalid_read_syntax, Fcons (make_string ("#", 1), Qnil));
  case ';':
    while ((c = READCHAR) >= 0 && c != '\n');
    goto retry;
  case '\'': {
    return Fcons (Qquote, Fcons (read0 (readcharfun), Qnil));
  }
  case '?': {
    Lisp_Object val;
    XSETTYPE (val, Lisp_Int);
    XSETINT (val, READCHAR);
    if (XINT (val) == '\\') {
      XSETINT (val, read_escape (readcharfun));
    }
    return val;
  }
  case '\"': {
    char *p = read_buffer;
    char *end = read_buffer + read_buffer_size;
    int c;
    Lisp_Object val;
    int cancel = 0;
    while ((c = READCHAR) >= 0 &&
	   (c != '\"' || (c = READCHAR) == '\"')) {
      if (p == end) {
	char *new = (char *) realloc (read_buffer, read_buffer_size *= 2);
	p += new - read_buffer;
	read_buffer += new - read_buffer;
	end = read_buffer + read_buffer_size;
      }
      if (c == '\\') {
	c = read_escape (readcharfun);
      }
      /* c is -1 if \ newline has just been seen */
      if (c < 0) {
	if (p == read_buffer) {
	  cancel = 1;
	}
      } else {
	*p++ = c;
      }
    }
    UNREAD (c);
    /* If purifying, and string starts with \ newline, return zero
       instead.  This is for doc strings that we are really going
       to find in etc/DOCSTRnnnn */
    if (!NULL (Vpurify_flag) && cancel) {
      return make_number (0);
    }
    if (read_pure) {
      return make_pure_string (read_buffer, p - read_buffer);
    } else {
      return make_string (read_buffer, p - read_buffer);
    }
  }
  default:
    if (c <= 040) {
      goto retry;
    }
    {
      char *p = read_buffer;
      {
	char *end = read_buffer + read_buffer_size;
	int escaped = 0;
	while (c > 040 && 
	       !(c == '\"' || c == '\'' || c == ';' || c == '?'
		 || c == '(' || c == ')' || c =='.'
		 || c == '[' || c == ']' || c == '#')){
	  if (p == end) {
	    char *new = (char *) realloc (read_buffer, read_buffer_size *= 2);
	    p += new - read_buffer;
	    read_buffer += new - read_buffer;
	    end = read_buffer + read_buffer_size;
	  }
	  if (c == '\\')
	    escaped = 1,  c = READCHAR;
	  *p++ = c;
	  c = READCHAR;
	}
	if (p == end) {
	  char *new = (char *) realloc (read_buffer, read_buffer_size *= 2);
	  p += new - read_buffer;
	  read_buffer += new - read_buffer;
	  end = read_buffer + read_buffer_size;
	}
	*p = 0;
	UNREAD (c);
      }
      /* Is it an integer? */
      {
	char *p1;
	Lisp_Object val;
	p1 = read_buffer;
	if (*p1 == '+' || *p1 == '-') p1++;
	if (p1 != p) {
	  while (p1 != p && (c = *p1) >= '0' && c <= '9') {
	    p1++;
	  }
	  if (p1 == p) {
	    /* It is. */
	    XSETTYPE (val, Lisp_Int);
	    XSETINT (val, atoi (read_buffer));
	    return val;
	  }
	}
      }
      return intern (read_buffer);
    }
  }
}

static Lisp_Object read_vector (Lisp_Object readcharfun) {
  int i;
  int size;
  Lisp_Object *ptr;
  Lisp_Object tem, vector;
  struct Lisp_Cons *otem;
  Lisp_Object len;
  tem = read_list (1, readcharfun);
  len = Flength (tem);
  vector = (read_pure ?
	    make_pure_vector (XINT (len)) :
	    Fmake_vector (len, Qnil));
  size = XVECTOR (vector)->size;
  ptr = XVECTOR (vector)->contents;
  for (i = 0; i < size; i++) {
    ptr[i] = read_pure ? Fpurecopy (Fcar (tem)) : Fcar (tem);
    otem = XCONS (tem);
    tem = Fcdr (tem);
    free_cons (otem);
  }
  return vector;
}
  
/* flag = 1 means check for ] to terminate rather than ) and
   flag = -1 means check for starting with defun and make structure pure.  */
static Lisp_Object read_list (int flag, Lisp_Object readcharfun) {
  /* -1 means check next element for defun,
     0 means don't check,
     1 means already checked and found defun. */
  int defunflag = flag < 0 ? -1 : 0;
  Lisp_Object elt,
    val,
    tail;
  val = Qnil;
  tail = Qnil;
  while (1) {
    elt = read1 (readcharfun);
    if (XTYPE (elt) == Lisp_Internal) {
      if (flag > 0) {
	if (XINT (elt) == ']') {
	  return val;
	} else {
	  Fsignal (Qinvalid_read_syntax,
		   Fcons (make_string (") or . in a vector", 18),
			  Qnil));
	}
      }
      if (XINT (elt) == ')') {
	return val;
      }
      if (XINT (elt) == '.') {
	if (!NULL (tail))
	  tail = Fsetcdr (tail, read0 (readcharfun));
	else
	  val = read0 (readcharfun);
	elt = read1 (readcharfun);
	if (XTYPE (elt) == Lisp_Internal && XINT (elt) == ')')
	  return val;
	Fsignal (Qinvalid_read_syntax, Fcons (make_string (". in wrong context", 18), Qnil));
      }
      Fsignal (Qinvalid_read_syntax, Fcons (make_string ("] in a vector", 13), Qnil));
    }
    if (!NULL (tail))
      tail = Fsetcdr (tail, (read_pure && flag <= 0 ? pure_cons : Fcons) (elt, Qnil));
    else
      tail = val = (read_pure && flag <= 0 ? pure_cons : Fcons) (elt, Qnil);
    if (defunflag < 0)
      defunflag = EQ (elt, Qdefun);
    else if (defunflag > 0)
      read_pure = 1;
  }
}

static int read_escape (Lisp_Object readcharfun) {
  int c = READCHAR;
  switch (c) {
  case 'a':
    return '\a';
  case 'b':
    return '\b';
  case 'e':
    return 033;
  case 'f':
    return '\f';
  case 'n':
    return '\n';
  case 'r':
    return '\r';
  case 't':
    return '\t';
  case 'v':
    return '\v';
  case '\n':
    return -1;
  case 'M':
    c = READCHAR;
    if (c != '-')
      error ("Invalid escape character syntax");
    c = READCHAR;
    if (c == '\\')
      c = read_escape (readcharfun);
    return c | 0200;
  case 'C':
    c = READCHAR;
    if (c != '-')
      error ("Invalid escape character syntax");
  case '^':
    c = READCHAR;
    if (c == '\\')
      c = read_escape (readcharfun);
    return c & 037;
  case '0':
  case '1':
  case '2':
  case '3':
  case '4':
  case '5':
  case '6':
  case '7': {
    int i = c - '0';
    int count = 0;
    while (++count < 3) {
      if ((c = READCHAR) >= '0' && c <= '7') {
	i *= 8;
	i += c - '0';
      } else {
	UNREAD (c);
	break;
      }
    }
    return i;
  }
  default:
    return c;
  }
}

Lisp_Object Vobarray;
Lisp_Object initial_obarray;

/* CHECK_OBARRAY assumes the variable Item is available */
#define CHECK_OBARRAY(obarray) \
  if (XTYPE (obarray) != Lisp_Vector) \
    { tem = obarray; obarray = initial_obarray; \
      wrong_type_argument (Qvectorp, tem); }

static int hash_string ();
Lisp_Object oblookup ();

Lisp_Object intern (chr* str) {
  Lisp_Object tem;
  int len = strlen (str);
  CHECK_OBARRAY (Vobarray);
  tem = oblookup (Vobarray, str, len);
  if (XTYPE (tem) == Lisp_Symbol) {
    return tem;
  }
  return Fintern ((!NULL (Vpurify_flag) ? make_pure_string : make_string)
		  (str, len),
		  Vobarray);
}

DEFUN ("intern", Fintern, Sintern, 1, 2, 0,
  "Return the symbol whose name is STRING.\n\
A second optional argument specifies the obarray to use;\n\
it defaults to the value of  obarray.")
  (Lisp_Object str, Lisp_Object obarray) {
  int hash;
  Lisp_Object tem, sym, *ptr;
  int sym_passed = 0;
  if (NULL (obarray)) {
    CHECK_OBARRAY (Vobarray);
    obarray = Vobarray;
  } else {
    CHECK_VECTOR (obarray, 1);
  }
  if (XTYPE (str) == Lisp_Symbol) {
    sym = str;
    sym_passed = 1;
    str = Fsymbol_name (str);
  } else {
    CHECK_STRING (str, 0);
  }
  tem = oblookup (obarray, XSTRING (str)->data, XSTRING (str)->size);
  if (XTYPE (tem) != Lisp_Int) {
    return tem;
  }
  if (!sym_passed) {
    if (!NULL (Vpurify_flag)) {
      str = Fpurecopy (str);
    }
    sym = Fmake_symbol (str);
  }
  ptr = &XVECTOR (obarray)->contents[XINT (tem)];
  if (XTYPE (*ptr) == Lisp_Symbol) {
    XSYMBOL (sym)->next = XSYMBOL (*ptr);
  } else {
    XSYMBOL (sym)->next = 0;
  }
  *ptr = sym;
  return sym;
}

DEFUN ("intern-soft", Fintern_soft, Sintern_soft, 1, 2, 0,
  "Return the symbol whose name is STRING, or nil if none exists yet.\n\
A second optional argument specifies the obarray to use;\n\
it defaults to the value of  obarray.")
  (Lisp_Object str, Lisp_Objectobarray) {
  int hash;
  Lisp_Object tem;
  if (NULL (obarray)) {
    CHECK_OBARRAY (Vobarray);
    obarray = Vobarray;
  } else {
    CHECK_VECTOR (obarray, 1);
  }
  if (XTYPE (str) == Lisp_Symbol) {
    str = Fsymbol_name (str);
  } else {
    CHECK_STRING (str, 0);
  }
  tem = oblookup (obarray, XSTRING (str)->data, XSTRING (str)->size);
  if (XTYPE (tem) != Lisp_Int) {
    return tem;
  }
  return Qnil;
}

Lisp_Object oblookup (Lisp_Object obarray, char* ptr, int size) {
  int hash,
    obsize;
  Lisp_Object tail;
  Lisp_Object bucket,
    tem;
  if (XTYPE (obarray) != Lisp_Vector || !(obsize = XVECTOR (obarray)->size)) {
    error ("Invalid obarray");
  }
  hash = hash_string (ptr, size) % obsize;
  bucket = XVECTOR (obarray)->contents[hash];
  for (tail = bucket; XSYMBOL (tail); XSETSYMBOL (tail, XSYMBOL (tail)->next)) {
    if (XSYMBOL (tail)->name->size != size) {
      continue;
    }
    if (bcmp (XSYMBOL (tail)->name->data, ptr, size)) {
      continue;
    }
    return tail;
  }
  XSETTYPE (tem, Lisp_Int);
  XSETINT (tem, hash);
  return tem;
}

static int hash_string (char* ptr, int len) {
  char *p = ptr;
  char *end = p + len;
  char c;
  int hash = 0;
  while (p != end) {
    c = *p++;
    if (c >= 0140) {
      c -= 40;
    }
    hash = ((hash<<3) + (hash>>28) + c);
  }
  return hash & 07777777777;
}

void map_obarray (Lisp_Object obarray, Lisp_Object fn, Lisp_Object arg) {
  int i;
  Lisp_Object tail;
  CHECK_VECTOR (obarray, 1);
  for (i = XVECTOR (obarray)->size - 1; i >= 0; i--) {
    for (tail = XVECTOR (obarray)->contents[i];
	 XTYPE (tail) == Lisp_Symbol && XSYMBOL (tail);
	 XSETSYMBOL (tail, XSYMBOL (tail)->next)) {
      (*fn) (tail, arg);
    }
  }
}

mapatoms_1 (Lisp_Object sym, Lisp_Object function) {
  call1 (function, sym);
}

DEFUN ("mapatoms", Fmapatoms, Smapatoms, 1, 2, 0,
  "Call FUNCTION on every symbol in OBARRAY.\n\
OBARRAY defaults to the value of  obarray.")
  (Lisp_Object function, Lisp_Object obarray) {
  Lisp_Object tem;
  if (NULL (obarray)) {
    CHECK_OBARRAY (Vobarray);
    obarray = Vobarray;
  } else {
    CHECK_VECTOR (obarray, 1);
  }
  map_obarray (obarray, mapatoms_1, function);
  return Qnil;
}

#define OBARRAY_SIZE 511

void init_obarray () {
  Lisp_Object oblength;
  XFASTINT (oblength) = OBARRAY_SIZE;
  Qnil = Fmake_symbol (make_pure_string ("nil", 3));
  Vobarray = Fmake_vector (oblength, make_number (0));
  initial_obarray = Vobarray;
  staticpro (&Vobarray);
  Fintern (Qnil, Vobarray);
  staticpro (&initial_obarray);
  Qunbound = Fmake_symbol (make_pure_string ("unbound", 7));
  XSYMBOL (Qnil)->function = Qunbound;
  XSYMBOL (Qunbound)->value = Qunbound;
  XSYMBOL (Qunbound)->function = Qunbound;
  Qt = intern ("t");
  XSYMBOL (Qnil)->value = Qnil;
  XSYMBOL (Qnil)->plist = Qnil;
  XSYMBOL (Qt)->value = Qt;
  Qvariable_documentation = intern ("variable-documentation");
  read_buffer_size = 100;
  read_buffer = (char *) malloc (read_buffer_size);
}

void defsubr (struct Lisp_Subr * sname) {
  Lisp_Object sym, subr;
  sym = intern (sname->symbol_name);
  XSETTYPE (XSYMBOL (sym)->function, Lisp_Subr);
  XSETSUBR (XSYMBOL (sym)->function, sname);
}

void defalias (struct Lisp_Subr* sname, char* string) {
  Lisp_Object sym,
    subr;
  sym = intern (string);
  XSETTYPE (XSYMBOL (sym)->function, Lisp_Subr);
  XSETSUBR (XSYMBOL (sym)->function, sname);
}

/* Define an "integer variable"; a symbol whose value is forwarded to
   a C variable of type int.  Sample call is DefIntVar
   ("indent-tabs-mode", &indent_tabs_mode, "Documentation"); */
void DefIntVar (char* namestring, int* address, char* doc) {
  Lisp_Object sym;
  sym = intern (namestring);
  XSETTYPE (XSYMBOL (sym)->value, Lisp_Intfwd);
  XSETINTPTR (XSYMBOL (sym)->value, address);
  Fput (sym, Qvariable_documentation,
	make_pure_string (doc, strlen (doc)));
}

/* Similar but define a variable whose value is T if address contains
   1, NIL if address contains 0 */
void DefBoolVar (char* namestring, int* address, char* doc) {
  Lisp_Object sym;
  sym = intern (namestring);
  XSETTYPE (XSYMBOL (sym)->value, Lisp_Boolfwd);
  XSETINTPTR (XSYMBOL (sym)->value, address);
  Fput (sym, Qvariable_documentation,
	make_pure_string (doc, strlen (doc)));
}

/* Similar but define a variable whose value is the Lisp Object stored
   at address. */
void DefLispVar (char* namestring, Lisp_Object* address, char* doc) {
  Lisp_Object sym;
  sym = intern (namestring);
  XSETTYPE (XSYMBOL (sym)->value, Lisp_Objfwd);
  XSETOBJFWD (XSYMBOL (sym)->value, address);
  Fput (sym, Qvariable_documentation,
	make_pure_string (doc, strlen (doc)));
}

/* Similar but define a variable whose value is the Lisp Object stored
   in the current buffer.  address is the address of the slot in the
   buffer that is current now. */
void DefBufferLispVar (char* namestring, Lisp_Object* address, char* doc) {
  Lisp_Object sym;
  sym = intern (namestring);
  XSETTYPE (XSYMBOL (sym)->value, Lisp_Buffer_Objfwd);
  XSETOBJFWD (XSYMBOL (sym)->value, (Lisp_Object *)((char *)address - (char *)bf_cur));
  Fput (sym, Qvariable_documentation,
	make_pure_string (doc, strlen (doc)));
}

init_read () {
  Vvalues = Qnil;
  Vload_path = decode_env_path ("EMACSLOADPATH", PATH_LOADSEARCH);
  if (!NULL (Vpurify_flag))
    Vload_path = Fcons (build_string ("../lisp"), Vload_path);
}

void syms_of_read () {
  defsubr (&Sread);
  defsubr (&Sread_from_string);
  defsubr (&Sintern);
  defsubr (&Sintern_soft);
  defsubr (&Sload);
  defsubr (&Seval_current_buffer);
  defsubr (&Seval_region);
  defsubr (&Sread_char);
  defsubr (&Sget_file_char);
  defsubr (&Smapatoms);
  
  DefLispVar ("obarray", &Vobarray,
    "Symbol table for use by  intern  and  read.\n\
It is a vector whose length ought to be prime for best results.\n\
Each element is a list of all interned symbols whose names hash in that bucket.");

  DefLispVar ("values", &Vvalues,
    "List of values of all expressions which were read, evaluated and printed.\n\
Order is reverse chronological.");

  DefLispVar ("standard-input", &Vstandard_input,
    "Stream for read to get input from.\n\
See documentation of read for possible values.");
  Vstandard_input = Qt;

  DefLispVar ("load-path", &Vload_path,
    "*List of directories to search for files to load.\n\
Each element is a string (directory name) or nil (try default directory).\n\
Initialized based on EMACSLOADPATH environment variable, if any,\n\
otherwise to default specified in by file paths.h when emacs was built.");

  Qstandard_input = intern ("standard-input");
  staticpro (&Qstandard_input);
  Qread_char = intern ("read-char");
  staticpro (&Qread_char);
  Qget_file_char = intern ("get-file-char");
  staticpro (&Qget_file_char);
  unrch = -1;
}
