@device(postscript)
@Make(manual)
@disable(figurecontents)
@LibraryFile(Garnet)
@Use(Bibliography = "garnet.bib")

@pageheading(immediate) @comment(no header on title page)
@String(TitleString = "Aggregadgets")
@begin(TitlePage)
@begin(TitleBox)
@blankspace(0.6 inch)
@Bg(Aggregadgets, Aggrelists,
& Aggregraphs
Reference Manual)

@b{Andrew Mickish
Roger B. Dannenberg
Philippe Marchal
David Kosbie
A. Bryan Loyall}
@BlankSpace(0.3 line)
@value[date]
@end(TitleBox)
@center[@b(Abstract)]
@begin(Text, spacing=1.1)
Aggregadgets and aggrelists are objects used to define natural hierarchies
of other objects in the Garnet system.  They allow the interface designer to
group graphical objects and associated behaviors into a single prototype
object by declaring the structure of the components.
Aggrelists are particularly useful in the creation of menu-type objects,
whose components are a sequence of similar items corresponding to a list
of elements.  Aggrelists will automatically maintain the layout of the
graphical list of objects.  Aggregraphs are similarly used to create and
maintain graph structures.

@blankspace(0.5 inch)
@include(creditetc.mss)
@end(text)
@end(TitlePage)


@include(pagenumbers.mss)
@set(Page = aggregadgets-first-page)

@Chapter(Aggregadgets)

@section(Accessing Aggregadgets and Aggrelists)
@index(loading aggregadgets)
The aggregadgets and aggrelists files are automatically loaded when the
file @pr(garnet-loader.lisp) is used to load Garnet.  The
@pr(garnet-loader) file uses one loader file for both aggregadgets
and aggrelists called @pr(aggregadgets-loader.lisp).  Loading this file
causes the KR, Opal, and Interactors files to be loaded also.

Aggregadgets and aggrelists reside in the @pr(Opal) package.  
All identifiers in this manual are exported from the @pr(Opal) package unless
another package name is explicitly given.  These identifiers can be
referenced by using the @pr(opal) prefix, e.g. @pr(opal:aggregadget);
the package name may be dropped if the line
@programexample[(use-package "OPAL")]
is executed before referring to any object in that package.

@section(Aggregadgets)

During the construction of a complicated Garnet interface, the designer will
frequently be required to arrange sets of objects into groups
that are easy to manipulate.  These sets may have intricate dependencies among
the objects, or possess a hierarchical structure that suggests a further
subgrouping of the individual objects.  Interactors may also be associated with
the objects that should intuitively be defined along with the objects
themselves.

Aggregadgets provide the designer with a straightforward method for the
definition and use of sets of Garnet objects and interactors.  When an
aggregadget is supplied
with a list of object definitions, Garnet will internally create instances
of those objects and add them to the aggregadget as components.  If the
objects are given names, Garnet will create slots in the aggregadget
which point to the objects, granting easy access to the components.
Interactors that manipulate the components of
the aggregadget may be similarly defined.

By creating instances of aggregadgets, the designer actually groups the
objects and interactors under a single prototype (class) name.  The defined
prototype may be used repeatedly to create more instances of the defined
group.  To illustrate this feature of aggregadgets, consider the schemata
shown below:
@begin(programexample)
(create-instance 'MY-GROUP opal:aggregadget
   (:parts
           ...)       @i(; some group of graphical objects)
   (:interactors
           ...))      @i(; some group of interactors)

(create-instance 'GROUP-1 MY-GROUP)

(create-instance 'GROUP-2 MY-GROUP
   ...)               @i(; definition of more slots)
@end(programexample)

The schema MY-GROUP defines a set of associated graphical objects and
interactors using an instance of the @pr(opal:aggregadget) object.  The
schemata @pr(group-1) and @pr(group-2) are instances of the @pr(my-group)
prototype which inherit all of the parts and behaviors defined in the
prototype.  The @pr(group-2) schema additionally defines new slots in the
aggregadget for some special purpose.


@subsection(How to Use Aggregadgets)
@label(what-an-agg)
@label(parts-syntax-sec)
@Index(aggregadget)
@index(parts in aggregadgets)
In order to group a set of objects together as components of an aggregadget,
the designer must define the objects in the @pr(:parts) slot of the
aggregadget.

The syntax of the @pr(:parts) slot is a backquoted list of lists, where
each inner list defines one component of the aggregadget.
The definition of each component includes a keyword that will be used as a
name for that part
(or NIL if the part is to be unnamed), the prototype of that part, and a
set of slot definitions that customize the component from the prototype.

The aggregadget will internally convert this list of parts into components of
the aggregadget, with each part named by the keyword provided (or unnamed,
if the keyword is NIL).

Everything inside the backquote that should be evaluated immediately must be
preceded by a comma.  Usually the following will need commas:
the prototype of the component, variable names, calls to @pr(formula)
and @pr(o-formula), etc.

After an aggregadget is created, the designer should not refer to the
@pr(:parts) slot.  Each component may be accessed by name as a slot of the
aggregadget.  Additionally, all components are listed in the
@pr(:components) slot just as in aggregates.
@index(components slot)  As with aggregates, components are listed
in display order, that is, @i(from back to front).

A short example of an aggregadget definition
is shown in figure @ref(check-mark), and the picture of this
aggregadget is in figure @ref(simple-expl-pict-ref).

@begin(figure)
@begin(programexample)
(create-instance 'CHECK-MARK opal:aggregadget
   (:parts
    `((:left-line ,opal:line
                  (:x1 70)
                  (:y1 45)
                  (:x2 95)
                  (:y2 70))
      (:right-line ,opal:line
                   (:x1 95)
                   (:y1 70)
                   (:x2 120)
                   (:y2 30)))))
@end(programexample)
@caption(A simple CHECK-MARK aggregadget.)
@tag(check-mark)
@end(figure)

@begin(figure)
@center{@graphic(PostScript="aggregadgets/agg-check-mark.ps",magnify=.75, BoundingBox=File)}

@caption(The picture of the CHECK-MARK aggregadget.)
@tag(simple-expl-pict-ref)
@end(figure)

Of course, the designer may define other slots in the aggregadget besides the
@pr(:parts) slot.  One convenient programming style involves the 
definition of several slots in the top-level aggregadget (such as
@pr(:left), @pr(:top), etc.) with formulas in several components that refer
to these values, thereby allowing a change in one top-level slot to
propagate to all dependent slots in the components.  Slots of components may
also contain formulas that refer to other components (see section
@ref(agg-dependencies)).


@Subsection(Named Components)

When keywords are given in the @pr(:parts) list that correspond to each
component, those keywords are used as names for the components.  In figure
@ref(check-mark), the names are @pr(:left-line) and @pr(:right-line).
Since these names were supplied, the slots @pr(:left-line) and @pr(:right-line)
are set in the CHECK-MARK aggregadget with the components themselves as values.
That is, @pr[(gv CHECK-MARK :left-line)] yields the actual component that
was created from the @pr(:parts) description.

The slot @pr(:known-as) in the component is also set with the name of the
component.  In the example above, @pr[(gv CHECK-MARK :left-line :known-as)]
yields @pr(:left-line).  Another way to look at these slots and objects is
shown in figures @ref(agg-ps-ref) and @ref(part-ps-ref).

When adding a new component to an aggregadget, you can set the @pr(:known-as)
slot of the component with a keyword name, which will be used in the top-level
aggregadget as a slot name that points directly to the new component.  The
example at the end of section @ref[constants-and-aggregadgets] illustrates
the idea of setting the @pr(:known-as) slot.

@begin(group)
@begin(figure)
@bar()
@begin(programexample)

@b(lisp>) (ps CHECK-MARK)

{#k<CHECK-MARK>
  :RIGHT-LINE = #k<KR-DEBUG:RIGHT-LINE-226>
  :LEFT-LINE = #k<KR-DEBUG:LEFT-LINE-220>
  :COMPONENTS = #k<KR-DEBUG:LEFT-LINE-220> #k<KR-DEBUG:RIGHT-LINE-226>
  ...
  :PARTS = ((:LEFT-LINE #k<OPAL:LINE>
                        (:X1 70) (:Y1 45) (:X2 95) (:Y2 70))
            (:RIGHT-LINE #k<OPAL:LINE>
                         (:X1 95) (:Y1 70) (:X2 120) (:Y2 30)))
  ...
  :IS-A = #k<OPAL:AGGREGADGET>
}
NIL
@b(lisp>)
@end(programexample)
@caption(The printout of the CHECK-MARK aggregadget.)
@tag(agg-ps-ref)
@end(figure)
@index(components slot)
@end(group)

@bar()

@begin(figure)
@begin(programexample)

@b[lisp>] (ps (gv CHECK-MARK :right-line))

{#k<KR-DEBUG:RIGHT-LINE-226>
  :PARENT =  #k<CHECK-MARK>
  :KNOWN-AS =  :RIGHT-LINE
  ...
  :Y2 =  30
  :X2 =  120
  :Y1 =  70
  :X1 =  95
  :IS-A =  #k<OPAL:LINE>
}
NIL
@b[lisp>] 

@end(programexample)
@caption(The @pr(:right-line) component of CHECK-MARK.)
@tag(part-ps-ref)
@bar()
@end(figure)

As shown in figure @ref(agg-ps-ref), CHECK-MARK has two components:
RIGHT-LINE-226 which is a line created according to the definition of 
@pr(:right-line) in the @pr(:parts) slot of the CHECK-MARK
aggregadget, and LEFT-LINE-220 corresponding to the definition of the
@pr(:left-line) part.  The CHECK-MARK
aggregadget also has two slots, @pr(:right-line) and @pr(:left-line), whose
values are the corresponding components.


@begin(group)
@SubSection(Destroying Aggregadgets)

@index(destroy)
@pr(opal:Destroy) @i(gadget)@value(method)

@index(destroy-me)
@pr(opal:Destroy-Me) @i(gadget)@value(method)

The @pr(destroy) method destroys an aggregadget or aggrelist 
and its instances.
To destroy a gadget means to destroy its interactors, components,
and item-prototype-object as well as the gadget schema itself.
The @pr(destroy-me) method for
aggregadgets and aggrelists destroys the prototype but not its
instances.  @p(Note:) users of gadgets should call @pr(destroy);
implementors of subclasses should override @pr(destroy-me).
@end(group)


@subsection(Constants and Aggregadgets)
@index(constants in aggregadgets)
@label(constants-and-aggregadgets)
The ability to define constant slots is an advanced feature of Garnet that is
discussed in detail in the KR manual.  However, the aggregadgets use
some of the features of constant slots by default.

All aggregadgets created with an initial @pr(:parts) list have
constant @pr(:components).  That is, after the aggregadget has
been created with all of its parts, the @pr(:components) slot becomes
constant automatically, and the components of the aggregadget are
not normally modifiable.  Also, the @pr(:known-as) slot of each part
and the slot in the aggregadget corresponding to the name of each
part is constant.  By declaring these slots constant, Garnet is able
to automatically get rid of the greatest number of formulas possible,
thereby freeing up memory for other objects.

For example, given the following instance of an @pr(aggregadget),
@begin(programexample)
(create-instance 'MY-AGG opal:aggregadget
  (:parts
   `((:obj1 ,opal:rectangle
            (:left 20) (:top 40))
     (:obj2 ,opal:circle
            (:left 50) (:top 10)))))
@end(programexample)
the slots @pr(:components), @pr(:obj1), and @pr(:obj2) will be
constant in MY-AGG.  The result is that you cannot remove components
or add new components to this aggregadget without disabling the
constant mechanism.

If you really want to add another component to the aggregadget, you
could use the macro @pr(with-constants-disabled), which is described
in the KR Manual:
@begin(programexample)
(with-constants-disabled
  (opal:add-component MY-AGG (create-instance NIL opal:roundtangle
                               (:known-as :obj3)  @i(; will become a constant slot)
                               (:left 40) (:top 20))))
@end(programexample)
Adding components to a constant aggregadget is discouraged because
the aggregadget's dimension formulas that
were already thrown away (if they were evaluated) will not be updated with the
dimensions of the new components.  That is, if OBJ3 in the example
above is outside of the original bounding box of MY-AGG
(calculated by the formulas in MY-AGG's @pr[:left], @pr[:top], @pr[:width],
and @pr[:height] slots), then Opal will fail to display the new
component correctly because it only updates the area enclosed by
MY-AGG's bounding box. 

A better solution than forcibly adding components is to create a
non-constant aggregadget to begin with.  Since only aggregadgets that
are created with a @pr(:parts) slot are constant, you should start with an
aggregadget without a @pr(:parts) list, and add your components using
@pr(add-component).  Thus, the better way to build the aggregadet above is:
@begin(programexample)
(create-instance 'MY-AGG opal:aggregadget)
(opal:add-components MY-AGG (create-instance NIL opal:rectangle
                              (:known-as :obj1)
                              (:left 20) (:top 40))
                            (create-instance NIL opal:circle
                              (:known-as :obj2)
                              (:left 50) (:top 10)))
@i(; Then later...)
(opal:add-component MY-AGG (create-instance NIL opal:roundtangle
                             (:known-as :obj3)
                             (:left 40) (:top 20)))
@end(programexample)
Note that you will have to supply your own @pr(:known-as) slots in the
components if you want the aggregadet to have slots referring to those
components.


@subsection(Implementation of Aggregadgets)
@label(known-as-sec)
An aggregadget is an instance of the prototype @pr(opal:aggregate),
with an initialize method that interprets the @pr(:parts) slot
and provides other functions.
This initialize method performs the following tasks:

@begin(itemize)
an instance of every part is created,

all these instances are added (with @pr(add-component)) as the components
of the aggregadget,

for each part, a slot is created in the aggregate. The name of this slot is
the name of the part, and its value is the instance of the corresponding
part.

The slot @pr(:known-as) in the part is set with the part's name.

In some cases (described in detail later), some or all of the
structure of the prototype aggregadget is inherited by the new instance. 
@end(itemize)


@subsection(Dependencies Among Components)
@Label(agg-dependencies)
@index(dependencies)
@indexsecondary(Primary="Formulas", Secondary="in aggregadgets")
@index(o-formula)

Aggregadgets are designed to facilitate the definition of dependencies among
their components.  When a slot of one component depends on the value of a
slot in another component of the same aggregadget, that dependency is
expressed using a formula.

The aggregadget is considered the parent of
the components, and the components are all siblings within the aggregadget.
Thus, the @pr(:parent) slot of each component can be used to travel up the
hierarchy, and the slot names of the aggregadget and its components can be
used to travel down.

Consider the following modification to the CHECK-MARK schema
defined in section @ref(what-an-agg).  In figure @ref(check-mark), the
@pr(:x1) and @pr(:y1) slots of the @pr(:right-line) object are the same as
the @pr(:x2) and @pr(:y2) slots of the @pr(:left-line) object so that
the two lines meet at a common point.  Rather than explicitly
repeating these coordinates in the @pr(:right-line) object, dependencies
can be defined in the @pr(:right-line) object that cause its origin to always
be the terminus of the @pr(:left-line).  Figure @ref(modified-check-mark)
shows the definition of this modified schema.

@begin(figure)
@begin(programexample)
(create-instance 'MODIFIED-CHECK-MARK opal:aggregadget
   (:parts
    `((:left-line ,opal:line
                  (:x1 70)
                  (:y1 45)
                  (:x2 95)
                  (:y2 70))
      (:right-line ,opal:line
                   (:x1 ,(o-formula (gvl :parent :left-line :x2)))
                   (:y1 ,(o-formula (gvl :parent :left-line :y2)))
                   (:x2 120)
                   (:y2 30)))))
@end(programexample)
@caption(A modified CHECK-MARK schema.)
@tag(modified-check-mark)
@end(figure)

@index(commas)
Commas must precede the calls to @pr(o-formula) and the references to the
@pr(opal:line) prototype because these items must be evaluated
immediately.  Without commas, 
the @pr(o-formula) call, for example, would
be interpreted as a quoted list due to the backquoted @pr(:parts) list.

The macro @pr(gvl-sibling) is provided to abbreviate references between
the sibling components of an aggregadget:

@Index(gvl-sibling)
@pr(opal:Gvl-Sibling) @i(sibling-name) @pr(&rest) @i(slots) @value(macro)

For example, the @pr(:x1) slot of the @pr(:right-line) object in figure
@ref(modified-check-mark) may be
given the equivalent value
@begin(programexample)
,(o-formula (opal:gvl-sibling :left-line :x2))
@end(programexample)

@subsection(Multi-level Aggregadgets)

Aggregadgets can be used to define more complicated objects with a
multi-level hierarchical structure.  Consider the picture of a check-box
shown in figure @ref(check-box-pict-ref).

@begin(figure)
@center{@graphic(PostScript="aggregadgets/agg-check-box.PS",BoundingBox=file,magnify=.75)}
@caption(A picture of a check-box.)
@tag(check-box-pict-ref)
@end(figure)

The check-box can be considered a hierarchy of objects:  the CHECK-MARK
object defined in figure @ref(check-mark), and a box.  This
hierarchy is illustrated in figure @ref(check-box-hier-ref).

@begin(figure)
@begin(programexample)

                             check-box
                               /  \
                              /    \
                            box  check-mark
                                    /  \
                                   /    \
                            left-line   right-line
@end(programexample)
@caption(The hierarchical structure of a check-box.)
@tag(check-box-hier-ref)
@end(figure)

The CHECK-BOX hierarchy is implemented through aggregadgets in figure 
@ref(check-box-def-ref).  Although the CHECK-BOX schema defines the
@pr(:box) component explicitly, the details of the @pr(:mark) object have
been defined elsewhere in the CHECK-MARK schema (see 
figure @ref(check-mark)).
The aggregadget definition for the CHECK-MARK part could have been
written out explicitly, as in the more complicated CHECK-BOX schema of
figure @ref(custom-check-box1).  However, the CHECK-BOX definition
presented here uses a modular approach that allows the reuse of the
CHECK-MARK schema in other applications.

@begin(figure)
@begin(programexample)
(create-instance 'CHECK-BOX opal:aggregadget
   (:parts
    `((:box ,opal:rectangle
            (:left 75)
            (:top 25)
            (:width 50)
            (:height 50))
      (:mark ,CHECK-MARK))))
@end(programexample)
@caption(The definition of a check-box.)
@tag(check-box-def-ref)
@end(figure)

See section @ref(Custom-check-box2) for another example of a modularized
multi-level aggregadget, and see section @ref(instances-sec) for 
information about inheriting structure from other multi-level aggregadgets.

@subsection(Nested Part Expressions for Aggregadgets)
Recall that parts are specified in a @pr(:parts) slot and
that the syntax for a part is
@begin(display)
(@i(name) @i(prototype) {@i(slot  value)}@+[*])
@end(display)
where @i(name) is either a keyword or NIL, @i(prototype) is a prototype
for the part, and @i(slots) is a list of local slot definitions.  
If @i(prototype) is an aggregadget, then @i(slots) may contain
another parts slot; thus, an entire aggregadget tree can be specified
by nested @pr(:parts) slots.

For example, figure @ref(x-box-fig) implements a box containing an X.
Notice how the @pr(:mark) part of X-BOX is an aggregadget containing
its own parts.
@begin(figure)
@center{@graphic(PostScript="aggregadgets/xbox-fig.PS",BoundingBox=File,magnify=.75)}
@begin(programexample)

;;; compute vertical position in :box according to a proportion
(defun vert-prop (frac) 
  (+ (gvl :parent :parent :box :top)
     (round (* (gvl :parent :parent :box :height) 
	       frac))))

;;; compute horizontal position in :box according to a proportion
(defun horiz-prop (frac)
  (+ (gvl :parent :parent :box :left)
     (round (* (gvl :parent :parent :box :width)
	       frac))))

(create-instance 'X-BOX opal:aggregadget
   (:left 20) 
   (:top 20)
   (:width 50)
   (:height 50)
   (:parts
    `((:box ,opal:rectangle
	    (:left ,(o-formula (gvl :parent :left)))
	    (:top  ,(o-formula (gvl :parent :top)))
	    (:width  ,(o-formula (gvl :parent :width)))
	    (:height ,(o-formula (gvl :parent :height))))
      (:mark ,opal:aggregadget
	     (:parts
	      ((:line1 ,opal:line
		       (:x1 ,(o-formula (horiz-prop 0.3)))
		       (:y1 ,(o-formula (vert-prop 0.3)))
		       (:x2 ,(o-formula (horiz-prop 0.7)))
		       (:y2 ,(o-formula (vert-prop 0.7))))
	       (:line2 ,opal:line
		       (:x1 ,(o-formula (horiz-prop 0.7)))
		       (:y1 ,(o-formula (vert-prop 0.3)))
		       (:x2 ,(o-formula (horiz-prop 0.3)))
		       (:y2 ,(o-formula (vert-prop 0.7)))))))))))

@end(programexample)
@caption(A box with an X, illustrating nested parts.)
@tag(x-box-fig)
@end(figure)


@begin(group)
@subsection(Creating a Part with a Function)
@IndexSecondary(Primary="Part-generating functions", Secondary="Single parts")
@IndexSecondary(Primary="Functions for parts", Secondary="Single parts")
@label(creating-part-fn)

Instead of defining a prototype as a part, the designer may specify a
function which will be called in order to generate the part.  This
feature can be useful when you plan to create several instances of an
aggregadget that are similar, but with different objects as parts.
For example, the aggregadgets in figure @ref(single-part-fn) all have
the same prototype.

@blankspace (0.25 inch)
@begin(figure)
@center{@graphic(PostScript="aggregadgets/single-part-fn.ps",magnify=.75,BoundingBox=File)}
@caption(Aggregadgets that generate a part through a function.)
@tag(single-part-fn)
@end(figure)
@end(group)

The syntax for generating a part with a function is to specify a
function within the @pr(:parts) list where a prototype for the part
would usually go.  The function must take one argument, which is the
aggregadget whose part is being generated.  Slots of the aggregadget
may be accessed at any time inside the function.

The purpose of the function is to return an
object that will be a component of the aggregadget.  You should
@u(not) add the part to the aggregadget yourself in the function.
However, you must be careful to always return an object that can be
used directly as a component.  For example, the @pr(opal:circle) object
would not be a suitable object to return, since it is the prototype of
many other objects.  Instead, you would return an @u[instance] of
@pr(opal:circle).

Additionally, you must be careful to consider the case where the
object to be used has already been used before.  That is, if you wanted
the function to return a rectangle more than once, the function must be
smart enough to return a particular rectangle the first time, and return
a different rectangle the second time and every time thereafter.
Usually it is sufficient to look at the @pr(:parent) slot of the
object to check if it is already part of another aggregadget.  The
following code, which generates the figure in @ref(single-part-fn),
takes this multiple usage of an object into consideration.

@begin(programexample)
(defun Get-Label (agg)
  (let* ((item (gv agg :item))
         @i[;; Item may be an object or a string]
	 (new-label (if (schema-p item)
			(if (gv item :parent)
			    @i[;; The item has been used already --]
			    @i[;; Use it as a prototype]
			    (create-instance NIL item)
			    @i[;; Use the item itself]
			    item)
		        (create-instance NIL opal:text
			  (:string item)
			  (:font (opal:get-standard-font
                                  :sans-serif :bold :very-large))))))
    (s-value new-label :left (o-formula (opal:gv-center-x-is-center-of (gvl :parent))))
    (s-value new-label :top (o-formula (opal:gv-center-y-is-center-of (gvl :parent))))
    new-label))

(create-instance 'AGG-PROTO opal:aggregadget
  (:item "Text")
  (:top 20) (:width 60) (:height 80)
  (:parts
   `((:frame ,opal:rectangle
	     (:left ,(o-formula (gvl :parent :left)))
	     (:top ,(o-formula (gvl :parent :top)))
	     (:width ,(o-formula (gvl :parent :width)))
	     (:height ,(o-formula (gvl :parent :height))))
     (:label ,#'Get-Label))))

(create-instance 'CIRCLE-LABEL opal:circle
  (:width 30) (:height 30)
  (:line-style NIL)
  (:filling-style opal:black-fill))

(create-instance 'SQUARE-LABEL opal:rectangle
  (:width 30) (:height 30)
  (:line-style NIL)
  (:filling-style opal:black-fill))

(create-instance 'AGG1 AGG-PROTO
  (:left 10)
  (:item CIRCLE-LABEL))

(create-instance 'AGG2 AGG-PROTO
  (:left 90)
  (:item SQUARE-LABEL))

(create-instance 'AGG3 AGG-PROTO
  (:left 170)
  (:item "W"))
@end(programexample)

Some of the functionality provided by a part-generating function is
overlapped by the customization syntax for aggregadget instances
described in section @ref(overriding-slots).  For example, the labels
in figure @ref(single-part-fn) could have been customized from the
prototype by supplying prototypes in the local @pr(:parts) list of
each instance.  However, for some applications using aggrelists, this
feature is indespensable (see section @ref[multi-parts-fn]).


@begin(group)
@subsection(Creating All of the Parts with a Function)
@IndexSecondary(Primary="Part-generating functions", Secondary="All parts")
@IndexSecondary(Primary="Functions for parts", Secondary="All parts")
@label(run-time)

As an alternative to supplying a list of component definitions in the
@pr(:parts) slot, the designer may instead specify a function which will
generate the parts of the aggregadget during its initialization.
This feature is useful when the components of the aggregadget are related in
some respect that is easily described by a function procedure, as in figure
@ref(multi-line-pict-ref).

@blankspace (0.25 inch)
@begin(figure)
@center{@graphic(PostScript="aggregadgets/agg-multi-line.ps",magnify=.75,BoundingBox=File)}
@caption(The multi-line picture.)
@tag(multi-line-pict-ref)
@end(figure)
@end(group)

This feature of aggregadgets is not usually used since, in most cases,
aggrelists supply the same functionality.  When all the components of an
aggregadget are instances of the same prototype, the designer should
consider implementing an itemized aggrelist, discussed in chapter
@ref(aggrelists).

The function may be specified in the @pr(:parts) slot as either a
previously defined function or a lambda expression.
The function must take one parameter:  the aggregadget whose parts are being
created.  The function must return a list of the created parts (e.g., a
list of instances of @pr(opal:line)) and,
optionally, a list of the names of the parts.  If supplied, the names must
be keywords
which will become slot names for the aggregadget, providing access to the
individual components (see section @ref(agg-dependencies)).  (@p(Note:) The
standard lisp function @pr(values) may be used to return two arguments from the
generating function.)
@index[values (lisp function)]

@index(multi-line)
Figure @ref(multi-line1-ref) shows how to create an aggregadget made
of multiple lines, with the end-points of the lines given in the
special slot @pr(:line-end-points).  The figure creates the object on
the left of figure @ref(multi-line-pict-ref).

@begin(figure)
@begin(programexample)
(create-instance 'MULTI-LINE opal:aggregadget
   (:parts
    `(,#'(lambda (self)
	   (let ((lines NIL))
	     (dolist (line-ends (gv self :lines-end-points))
	       (setf lines (cons (create-instance NIL opal:line
				   (:x1 (first line-ends))
				   (:y1 (second line-ends))
				   (:x2 (third line-ends))
				   (:y2 (fourth line-ends)))
				 lines)))
	     (reverse lines)))))
   (:lines-end-points '((10 10 100 100)
			(10 100 100 10)
			(55 10 55 100)
			(10 55 100 55))))
@end(programexample)

@caption(An aggregadget with a function to create the parts.)
@tag(multi-line1-ref)
@end(figure)


Figure @ref(multi-line2-ref) shows how to create the same aggregadgets as in
figure @ref(multi-line-pict-ref), but with a separately defined function rather
than a lambda expression.
In addition, this function returns the list of the names of
the parts.  Two instances of the aggregadget are created, with only one of
these instances having names for the lines.

@begin(figure)
@begin(programexample)
(defun Make-Lines (lines-agg)
  (let ((lines NIL))
    (dolist (line-ends (gv lines-agg :lines-end-points))
      (setf lines (cons (create-instance NIL opal:line
			   (:x1 (first line-ends))
			   (:y1 (second line-ends))
		           (:x2 (third line-ends))
			   (:y2 (fourth line-ends)))
			lines)))
    (values (reverse lines) (gv lines-agg :lines-names))))

(create-instance 'MY-MULTI-LINE1 opal:aggregadget
   (:parts `(,#'Make-Lines))
   (:lines-end-points '((10 10 100 100)
                        (10 100 100 10)
                        (55 10 55 100)
                        (10 55 100 55)))
   (:lines-names
    '(:down-diagonal :up-diagonal :vertical :horizontal)))

(create-instance 'MY-MULTI-LINE2 opal:aggregadget
   (:parts `(,#'Make-Lines))
   (:lines-end-points '((120 100 170 10)
                        (170 10 220 100)
                        (220 100 150 100))))
@end(programexample)

@caption(An aggregadget with a function to create named parts.)
@tag(multi-line2-ref)
@end(figure)

It should be noted that the use of a function to create parts is @i(not)
inherited.  If the @pr(:parts) slot is omitted, then the actual parts (not
the function that created the parts) are inherited from the prototype.  It
is possible to override the @pr(:initialize) method to obtain a different
instantiation convention, but probably it is simplest just always to specify
the @pr(:parts) slot indicating the function that creates parts.


@section(Interactors in Aggregadgets)
@label(agg-interactors)
@index(interactors)

Interactors may be grouped in aggregadgets in precisely the same way that
objects are grouped.  The slot @pr(:interactors) is analogous to the
@pr(:parts) slot, and may contain a list of interactor definitions that
will be attached to the aggregadget.

As with the @pr(:parts) slot, @pr(:interactors) must contain a backquoted
list of lists with commas preceding everything that should be evaluated
immediately@value(dash)prototypes, function calls, variable references, etc. 
The name of a function that generates a set of interactors can also be
given with the same parameters and functionality as the @pr(:parts)
function described in section @ref(run-time).
@index(function for :interactors)
@index(interactors function)

@index(behaviors slot)
If a keyword is supplied as the name for an interactor, then a slot with
that name will be
automatically created in the aggregadget, and the value of that slot will
be the interactor.  For example, in figure @ref(framed-text), a slot
called @pr(:text-inter) will be created in the aggregadget to refer to
the text interactor.
The system will also add to the aggregadget a @pr(:behaviors) slot, containing
a list of pointers to the interactors.  This slot is analogous to the
@pr(:components) slot for graphical objects.


@index(operates-on)
Each interactor will be given a new @pr(:operates-on) slot which is
analogous to the @pr(:parent) slot for component objects.  The
@pr(:operates-on) slot contains a pointer to the aggregadget that the
interactor belongs to.  This slot should be used when referring to the
aggregadget from within interactors.

@index(windows for interactors)
In order to activate any interactor in Garnet, its @pr(:window) slot must
contain a pointer to the window in which the interactor operates.
In most cases, the window for the interactor will be found in
the @pr(:window) slot of the aggregadget, which is internally
maintained by aggregates.  Hence, the following slot definition should be
included in all interactors defined in an aggregadget:
@begin(programexample)
(:window ,(o-formula (gv-local :self :operates-on :window)))
@end(programexample)
@p(Note:) in this formula, @pr(gv-local) is used to follow local
links @pr(:operates-on) and @pr(:window).  Using @pr(gv-local) instead of
@pr(gv) or @pr(gvl) when referring to these slots helps avoid accidental
references to these slots in the aggregdagets' prototype.
Most values for the @pr(:window) slots of aggregadget interactors will
resemble this formula.

The interactors are independent of the parts, and either feature
may be used with or without the other.  When using both parts and
interactors, any object may refer to any other using the methods described
in section @ref(agg-dependencies).

Figure @ref(framed-text) shows how to create a ``framed-text'' aggregadget
that allows the input and display of text. This aggregadget is made of two
parts, a frame (a rectangle) and a text object, and one interactor
(a text-interactor).  Figure @ref(agg-inter-ps-ref) is a partial printout of
the FRAMED-TEXT aggregadget with its built-in interactor, illustrating the
slots created by the system.  A picture of the aggregadget is shown in
figure
@ref(framed-text-pix).
@index(framed-text example)

@begin(figure)
@bar()
@begin(programexample)
(create-instance 'FRAMED-TEXT opal:aggregadget
   (:left 0)      @i(; Set these slots to determine)
   (:top 0)       @i(; the position of the aggregadget.) 
   (:parts
    `((:frame ,opal:rectangle
          (:left ,(o-formula (gvl :parent :left)))
          (:top ,(o-formula (gvl :parent :top)))
          (:width ,(o-formula (+ (gvl :parent :text :width) 4)))
          (:height ,(o-formula (+ (gvl :parent :text :height) 4))))
      (:text ,opal:text
          (:left ,(o-formula (+ (gvl :parent :left) 2)))
          (:top ,(o-formula (+ (gvl :parent :top) 2)))
          (:cursor-index NIL)
          (:string ""))))
   (:interactors
     @i[; Press on the text object (inside the frame) to edit the string]
    `((:text-inter ,inter:text-interactor
	  (:window ,(o-formula (gv-local :self :operates-on :window)))
          (:feedback-obj NIL)
          (:start-where ,(o-formula
                          (list :in (gvl :operates-on :text))))
          (:abort-event #\control-\g)
          (:stop-event (:leftdown #\RETURN))))))
@end(programexample)
@caption(Definition of an aggregadget with a built-in interactor.)
@tag(framed-text)
@end(figure)

@bar()

@begin(figure)
@begin(programexample)

@b[lisp>] (ps FRAMED-TEXT)
{#k<FRAMED-TEXT>
  ...
  :COMPONENTS =  #k<KR-DEBUG:FRAME-205> #k<KR-DEBUG:TEXT-207>
  :FRAME =  #k<KR-DEBUG:FRAME-205>
  :TEXT =  #k<KR-DEBUG:TEXT-207>
  :BEHAVIORS =  #k<KR-DEBUG:TEXT-INTER-214>
  :TEXT-INTER =  #k<KR-DEBUG:TEXT-INTER-214>
  ...
  :IS-A =  #k<OPAL:AGGREGADGET>
}
NIL
@b[lisp>] (ps (gv FRAMED-TEXT :text-inter))

{#k<KR-DEBUG:TEXT-INTER-214>
  ...
  :OPERATES-ON =  #k<FRAMED-TEXT>
  ...
  :IS-A =  #k<INTERACTORS:TEXT-INTERACTOR>
}
NIL
@b[lisp>] 

@end(programexample)
@caption(The printouts of an aggregadget and its attached interactor.)
@tag(agg-inter-ps-ref)
@end(figure)


@begin(figure)
@Center[@graphic(Postscript="aggregadgets/framed-text-pix.PS",boundingbox=File,magnify=.75)]
@caption(A picture of the FRAMED-TEXT aggregadget.)
@tag(framed-text-pix)
@end(figure)



@section(Instances of Aggregadgets)
@label(agg-insts)
The preceding chapter discussed the use of the @pr(:parts) slot
to define the structure of new aggregadgets.  Once an aggregadget
is created, the structure will be inherited by instances.  The
@pr(:parts) slot can be used to extend or override this default
structure.

@subsection(Default Instances of Aggregadgets)
@label(instances-sec)
By default, when an instance of an aggregadget is created,
an instance of each component and interactor is also created.
Figure
@ref(instance-fig) illustrates an aggregadget on the left and its instance
on the right.  Notice that each object within the prototype aggregadget
serves as a prototype for each corresponding object in the instance
aggregadget.  The structure of the instance aggregate matches the structure
of the prototype, including ``external'' references to objects not in either
aggregate, as illustrated by the reference from C to D.  Since D is external
to the aggregate, there is no D', and the reference to D is inherited by C'.


@begin(figure)
@center(@graphic(postscript = "aggregadgets/instance-fig.ps",magnify=.75,boundingbox=File))
@caption(A prototype aggregate and one instance.  The dashed lines
go from instances to their prototypes, solid lines 
join children to parents, and the dotted line from C to D represents 
a formula dependence which is inherited by C'.)
@tag(instance-fig)
@end(figure)

When creating instances, it is possible to override slots and parts
of the prototype aggregadget, provided that these slots were not declared
constant in the prototype.

@subsection(Overriding Slots and Structure)
@label(overriding-slots)
Just as instances of
KR objects can override slots with local values, aggregadgets can override
slots or even entire parts (objects) with local values.  The @pr(:parts)
and @pr(:interactors) syntax is used to override details of an
aggregadget when constructing an instance.

When creating an instance of an aggregadget that already has components,
there are several variations of the @pr(:parts) syntax that can be used
to inherit components.  As illustrated in these examples, if @i(any) parts
are listed in
a @pr(:parts) list, then @i(all) parts should be listed.  This is
explained further in section @ref(more-syntax-sec):
@begin(enumerate)
If the entire @pr(:parts) slot is omitted, then the components are
instantiated in the default manner described above.  For example,
@begin(programexample)
(create-instance 'NEW-X-BOX X-BOX (:left 100))
@end(programexample)
will instantiate the @pr(:box) and @pr(:mark) parts of @pr(x-box)
by default.

Any element in the list of parts may be a keyword rather than a list.
The keyword must name a component of the prototype, and an instance
of that component is created.  Parts are always added in the order
they are listed, regardless of their order in the prototype.
For example:
@begin(programexample)
(:parts `(:shadow :box :feedback))
@end(programexample)

@index{omit (keyword in aggregadgets)}
Any element in the list of parts may be a list of the form
@pr[(@i(name) :omit)], where @i(name) is the name of a component
in the prototype, and @pr(:omit) indicates that an instance of that
part is not included in the instance aggregadget.  For example:
@begin(programexample)
(:parts `((:shadow :omit)
	  :box
	  :feedback))
@end(programexample)

@index{modify (keyboard in aggregadgets)}
Any element in the list of parts may be a list of the form
@index[modify (keyword)]
@pr[(@i(name) :modify @i(slots))], where @i(name) is the part name,
@pr(:modify) means to use the default prototype, and @i(slots) is a
standard list of slot names and values which override slots inherited
from the prototype.  Only the changed slots
need to be listed; the others are inherited from the prototype.  [Note:
this is different from the @pr(:parts) slot, where you must list all the
parts if you are changing any of them.]
If the object is an aggregadget, then one of the
slots may be a @pr(:parts) list to further specify components.
For example:
@begin(programexample)
(:parts `((:shadow :modify (:offset 5))
	  :box
	  :feedback))
@end(programexample)

Any element of the list of parts may be a list of the form
@pr[(@i(name) @i(prototype) @i(slots))], as described in section
@ref(parts-syntax-sec).  This indicates that the part should be added
to the instance aggregadget.
If @i(name) names an existing component in the aggregadget, then
the new part will override the part that would otherwise be inherited.
@end(enumerate)


@subsection(Simulated Multiple Inheritance)
In some cases, it is desirable to inherit particular slots from
a default prototype object, but to override the actual prototype.
For example, one might want to change rectangles in a prototype
into circles but still inherit the @pr(:top) and @pr(:left) slots.
Alternatively, one might want to replace a number box with a dial
but still inherit a @pr(:color) slot from the prototype number box.

The @pr(:parts) syntax has a special variation to accomplish this form
of multiple inheritance.  If the keyword @pr(:inherit) occurs at the
top level in the @i(slots) list, then the next element of @i(slots)
must be a list of slot names.  All the slots not mentioned in the
@pr(:inherit) clause are inherited from the new prototype (the circle in
the example below).  For example:
@begin(programexample)
(:parts `((:shadow ,opal:circle
	    (:offset 5)
	    :inherit (:left :top :width :height :filling-style))
	  :box
	  :feedback))
@end(programexample)


@subsection(Instance Examples)
Figure @ref(circle-x-box-fig) illustrates how to override and inherit
parts from an aggregadget.  The prototype aggregadget is the @pr(x-box)
aggregadget shown in figure @ref(x-box-fig).  In the instance named
CIRCLE-X-BOX, a circle has been inserted between the box and the ``X''
mark, and the box has a gray fill.

@begin(figure)
@center{@graphic(PostScript="aggregadgets/circle-xbox-fig.PS",
                BoundingBox=File,magnify=.75)}
@begin(programexample)

(create-instance 'CIRCLE-X-BOX X-BOX
   (:left 150)
   (:top 160)
   (:parts 
    `((:box :modify (:filling-style ,opal:gray-fill))
      (:circle ,opal:circle
	       (:left ,(o-formula (+ (gvl :parent :left) 2)))
	       (:top ,(o-formula (+ (gvl :parent :top) 2)))
	       (:width ,(o-formula (- (gvl :parent :width) 4)))
	       (:height ,(o-formula (- (gvl :parent :height) 4)))
	       (:filling-style ,opal:white-fill))
      :mark))))
@end(programexample)
@caption(Adding a circle and changing the filling style in an instance
of the X-BOX aggregadget.)
@tag(circle-x-box-fig)
@end(figure)

In figure @ref(circle-box-fig), the CIRCLE-X-BOX aggregadget is
further modified by replacing the ``X'' with a circle.

@begin(figure)
@center{@graphic(PostScript="aggregadgets/circle-box-fig.PS",
                BoundingBox=File,magnify=.75)}
@begin(programexample)

(defun circle-box-test ()
  (create-instance 'CIRCLE-BOX CIRCLE-X-BOX
   (:left 150)
   (:top 220)
   (:parts
    `(:box 
      :circle
      (:mark :omit)
      (:inner-circle ,opal:circle
	     (:left ,(o-formula (+ (gvl :parent :left) 10)))
	     (:top ,(o-formula (+ (gvl :parent :top) 10)))
	     (:width ,(o-formula (- (gvl :parent :width) 20)))
	     (:height ,(o-formula (- (gvl :parent :height) 20))))))))
@end(programexample)
@caption(Omitting the ``X'' and adding an inner circle to the
CIRCLE-X-BOX aggregadget.)
@tag(circle-box-fig)
@end(figure)

@subsection(More Syntax: Extending an Aggregadget)
@label(more-syntax-sec)
Normally, each part of a prototype should be explicitly mentioned
in the @pr(:parts) list.  This is perhaps tedious, but it makes the
code clear.  There is one exception
that is provided to make it simple to add things to existing prototypes.

If @i(none) of the parts of a prototype are mentioned in the parts list,
then instances of @i(all) of the prototype's parts are included in
the instance aggregadget.  If additional parts are specified, they
are added after the default parts, so they will appear graphically on
top.  @i(It is
an error to mention some but not all of a prototype's parts in a @pr(:parts)
list.)  (The current implementation only looks to see if the @i(first)
part of the prototype is mentioned in the @pr(:parts) list in order to
decide whether or not to include all of the prototype parts.)  

Figure @ref(x-sq-box-fig) illustrates the extension of 
the @pr(:mark) part of the @pr(x-box) prototype with
a rectangle.  Since parts @pr(:line1)
and @pr(:line2) are not mentioned, they are included in the @pr(:mark) 
part automatically.

@begin(figure)
@center{@graphic(PostScript="aggregadgets/x-sq-box-fig.PS",
                BoundingBox=File,magnify=.75)}
@begin(programexample)

(defun x-sq-box-test ()
  (create-instance 'X-SQ-BOX X-BOX
    (:left 210)
    (:top 20)
    (:parts
     `(:box		; inherit the box with no change
       (:mark :modify	; modify the mark
	(:parts		; since :line1 and :line2 are not mentioned,
			; they are inherited as is
	 ((:square ,opal:rectangle	; add a new part to the mark
	      (:left ,(o-formula (horiz-prop 0.2)))
	      (:width ,(o-formula (- (horiz-prop 0.8) 
				     (horiz-prop 0.2))))
	      (:top ,(o-formula (vert-prop 0.2)))
	      (:height ,(o-formula (- (vert-prop 0.8) 
				      (vert-prop 0.2))))))))))))
@end(programexample)
@caption(Extending the x-box prototype with a new rectangle in the mark
part.)
@tag(x-sq-box-fig)
@end(figure)

@section(Aggrelists)
@Index(aggrelists)
@label(aggrelists)

Many interfaces require the arrangement of a set of objects in a graphical
list, such as menus and parallel lines.  Aggrelists are designed to
facilitate the arrangement of objects in graphical lists while providing
many customizable slots that determine the appearance of the list.  The
methods @pr(add-component) and @pr(remove-component) can be used to alter
the components in the list after the aggrelist has been instantiated.
(See section @ref(aggrelist-manipulation-sec).)

@index(itemized aggrelists)
A special style of aggrelists, called ``itemized aggrelists'', may be used
when the items of the list are all instances of the same prototype (e.g., all
items in a menu are text strings).
These aggrelists use the methods @pr(add-item) and @pr(remove-item)
to manipulate the components of the list.

Aggrelists are independent of aggregadgets and may be used separately or
inside aggregadgets.  Aggrelists may also have aggregadgets as components
in order to create objects such as menus or choice lists.

Interactors may be defined for aggrelists using the same methods that
implement interactors in aggregadgets (section @ref(agg-interactors)).

@begin(group)
@subsection(How to Use Aggrelists)

@blankspace(1 line)
The definition of the @pr(aggrelist) prototype in Opal is:
@blankspace(1 line)

@begin(programexample)
(create-instance 'opal:aggrelist opal:aggregate
 (:maybe-constant '(:left :top :width :height :direction :h-spacing :v-spacing
		    :indent :h-align :v-align :max-width :max-height
		    :fixed-width-p :fixed-height-p :fixed-width-size
		    :fixed-height-size :rank-margin :pixel-margin :items :visible))
 (:left 0)
 (:top 0)
 (:width (o-formula ...))
 (:height (o-formula ...))
 (:direction :vertical)	      @i[; Can be :horizontal, :vertical, or NIL]
 (:h-spacing 5)		      @i(; Pixels between horizontal elements)
 (:v-spacing 5)		      @i(; Pixels between vertical elements)
 (:indent 0)		      @i(; How much to indent on wraparound)
 (:h-align :left)	      @i(; Can be :left, :center, or :right)
 (:v-align :top)	      @i(; Can be :top, :center, or :bottom)
 (:max-width  (o-formula (...)))
 (:max-height (o-formula (...)))
 (:fixed-width-p NIL)	      @i[; Whether to use fixed-width-size]
 (:fixed-height-p NIL)        @i[; Whether to use fixed-height-size]
 (:fixed-width-size NIL)      @i[; The width of all components]
 (:fixed-height-size NIL)     @i[; The height of all components]
 (:rank-margin NIL)           @i[; If non-NIL, the number of components in each row/column]
 (:pixel-margin NIL)          @i[; Same as :rank-margin, but with pixels]
 (:head NIL)                  @i[; The first component (read-only slot)]
 (:tail NIL)                  @i[; The last component (read-only slot)]
 (:items NIL)                 @i[; List of the items or a number]
 (:item-prototype NIL)        @i[; Specification of prototype of the items (when itemized)]
 (:item-prototype-object NIL) @i[; The actual object, set internally (read-only slot)]
 ...)
@end(programexample)
@end(group)

Aggrelists are easily customized by providing values for the controlling
slots.  Any slot listed below may be given a value during the definition
of an aggrelist.  The slots can also be modified (using the KR function
@pr(s-value)) after the aggrelist is displayed to change the appearance of
the objects.  However, each slot has a default value and the designer
may choose to ignore most of the slots.

@index(constants in aggrelists)
The list in @pr(:maybe-constant) contains those slots that will be
declared constant in an aggrelist whose @pr(:constant) slot contains T.
That is, when you create an aggrelist with the slot @w{@pr[(:constant T)]},
then all of these slots are guaranteed not to change, and all formulas
that depend on those slots will be removed and replaced by absolute
values.  This removal of formulas has the potential to save a large amount
of storage space.

The following slots are available for customization of aggrelists:

@begin(description, leftmargin=10, indent=-6)

@pr(:left) @value(shortdash) The leftmost coordinate of the aggrelist
(default is 0).

@pr(:top) @value(shortdash) The topmost coordinate of the aggrelist
(default is 0).

@pr(:items) @value(shortdash) A number (indicating the number of items
in the aggrelist) or a list of values that will be used by the components.
If the value is a list, then do not destructively modify the value;
instead, set the value with a new list (using @pr(list)) or use @pr(copy-list).

@pr(:item-prototype) @value(shortdash) Either a schema or a
description of a schema (see section @ref[the-i-p-slot]).

@index(direction)
@pr(:direction) @value(shortdash) Either :@pr(horizontal),
@pr(:vertical) or NIL.  If the value is either @pr(:horizontal) or 
@pr(:vertical), the system will install values in the @pr(:left) and
@pr(:top) slots of each component, in order to lay out the
list properly according to the direction.  If the value is NIL, then the
designer must provide formulas for the @pr(:left) and @pr(:top)
slots of each component (default is @pr{:vertical}).

@index(v-spacing)
@pr(:v-spacing) @value(shortdash) Vertical spacing between elements
(default is 5). 

@index(h-spacing)
@pr(:h-spacing) @value(shortdash) Horizontal spacing between elements
(default is 5). 

@index(fixed-width-p)
@pr(:fixed-width-p) @value(shortdash) If set to T, all the components
will be placed in fields of constant width.  These fields will be of
the size of the widest component, unless the slot
@pr(:fixed-width-size) is non-NIL, in which case it will default to
the value stored there (default is NIL). 

@index(fixed-width-size)
@pr(:fixed-width-size) @value(shortdash) The width of all components,
if @pr(:fixed-width-p) is T (default is NIL).

@index(fixed-height-p)
@pr(:fixed-height-p) @value(shortdash) If set to T, all the components
will be placed in fields of constant height.  These fields will be of
the size of the tallest component, unless the slot
@pr(:fixed-height-size) is non-NIL, in which case it will default to
the value stored there (default is NIL). 

@index(fixed-height-size)
@pr(:fixed-height-size) @value(shortdash) The height of all components, if
@pr(:fixed-width-p) is T (default is NIL).

@index(h-align)
@pr(:h-align) @value(shortdash) The type of horizontal alignment to use within
a field (only applicable if @pr(fixed-width-p) is T).  Allowed values are
 @pr(:left), @pr(:center), or @pr(:right) (default is @pr{:left}).

@index(v-align)
@pr(:v-align) @value(shortdash) The type of vertical alignment to use within
a field (only applicable is @pr(fixed-height-p) is T).  Allowed values are
 @pr(:top), @pr(:center), or @pr(:bottom) (default is @pr{:top}).

@index(rank-margin)
@pr(:rank-margin) @value(shortdash) If non-NIL, then after this many
components, a new row will be started for horizontal lists, or a new
column for vertical lists (default is NIL).

@index(pixel-margin)
@pr(:pixel-margin) @value(shortdash) If non-NIL, then this acts as an
absolute position in pixels in the window; if adding the next component would
result in extending beyond this value, then a new row or column is started
(default is NIL).

@index(indent)
@pr(:indent) @value(shortdash) The amount to indent upon starting a new row/column (in pixels)
(default is 0).
@end(description)


@subsection(Itemized Aggrelists)
@index(itemized aggrelists)
When all the components of an aggrelist are instances of the same prototype,
the aggrelist is referred to as an itemized aggrelist.  This type of
aggrelist provides for the automatic generation of the components from a
specified item prototype.  This feature is convenient when creating objects
such as menus or button panels, whose components are all similar.
(In a non-itemized aggrelist, the components may be of several types,
though they still take advantage of the layout mechanisms of
aggrelists, as in section @ref[non-itemized-sec].)

To cause an aggrelist to generate its components from a prototype, the
@pr(:item-prototype) and the @pr(:items) slot may be set.

@paragraph(The :item-prototype Slot)
@index(item-prototype)
@label(the-i-p-slot)
The @pr(:item-prototype) slot contains a description of the
prototype object that will be used to create the items.  This slot is
analogous to the @pr(:parts) slot for aggregadgets.
Garnet builds an object from the @pr(:item-prototype) description and stores
this object in the @pr(:item-prototype-object) slot of the aggrelist.
@b(Do not specify or set the) @pr(:item-prototype-object) @b(slot).

The prototype may be any Garnet object, including
aggregadgets, and may be given either as an existing schema name 
or as a quoted list holding an object definition, as in
@begin(programexample)
(:item-prototype `(,opal:rectangle (:width 100)
                                   (:height 50)))
@end(programexample)
The keyword @pr(:modify) @index[modify (keyword)]
may be used to indicate changes to an inherited item prototype, as in
@begin(programexample)
(:item-prototype `(:modify (:width 100)
                           (:height 50)))
@end(programexample)
The prototype for the @pr(:item-prototype-object) in this case will be 
the @pr(:item-prototype-object)
of the prototype of the aggrelist being specified.
This form would be used to modify the default in some way (see section
@ref(modify-item-sec)).

If no local @pr(:item-prototype) slot is specified, the default is
to create an instance of the @pr(:item-prototype-object) of the 
prototype aggrelist.  If there is no @pr(:item-prototype-object), 
then this is not an itemized aggrelist (see section @ref(non-itemized-sec)).

@paragraph(The :items Slot)
@index(items)
The @pr(:items) slot holds either a number or a list.  If it is a
number @i(n), then @i(n) identical instances of @pr(:item-prototype-object)
will be created and added to the aggrelist.  If it is a list of @i(n)
elements, @i(n) instances of @pr(:item-prototype-object) will be
created and added to the aggrelist.

When @pr(:items) is a list of elements, the designer must define a formula
in the @pr(:item-prototype) that extracts the desired element from the list
for each component.  In a menu, for example, the @pr(:items) slot will
usually be a list of strings.  Components should index their individual
strings from the @pr(:items) list according to their @pr(:rank).  The
following slot 
definition, to be included in the @pr(:item-prototype), would yield this
functionality:
@begin(programexample)
@pr[(:string (o-formula (nth (gvl :rank) (gvl :parent :items))))]
@end(programexample)
This formula assigns the @i(n)th string in the @pr(:items) list to the
@i(n)th component of the aggrelist.@\

The @pr(:items) slot may also hold a nested list so that the components
can extract more than one value from it.  For example, if the components
of a menu are characterized both by a label and a function (to be called
when the item is selected), the @pr(:item) slot of the menu will be a list
of pairs '((@i[label] @i[function]) ...), and the components will
access their strings and associated functions with formulas such as:
@begin(programexample)
(:string (o-formula (first (nth (gvl :rank) (gvl :parent :items)))))
(:function (o-formula (second (nth (gvl :rank)
                                   (gvl :parent :items)))))
@end(programexample)

The list in the @pr(:items) list may not be destructively modified.  If you
need to modify the current value of the slot, you should create a new list
(e.g., with @pr(list)) or use @pr(copy-list) on the current value and modify
the resulting copied list.


@Paragraph(Aggrelist Components)
@index(components of aggrelists)

When the value of @pr(:items) changes, the number of components corresponding
to the change will be adjusted automatically during the next call to
@pr(opal:update).  In most cases, users will never have to do anything
special to cause the components to become consistent with the @pr(:items) list.

In some cases, an application might need to refer to the new components
(or the new positions of the components) @i(before) calling @pr(opal:update).
It is possible to explicitly adjust the number of components in the aggrelist
after setting the @pr(:items) list by calling:

@index(notice-items-changed)
@pr(opal:Notice-Items-Changed) @i(aggrelist)@value(method)

where @i(aggrelist) is the aggrelist whose @pr(:items) slot has changed.
This function will additionally execute the layout function on the components,
so that they will have up-to-date @pr(:left) and @pr(:top) values.


@paragraph(Constants and Aggrelists)
@label(constants-in-aggrelists)
@index(constants in aggrelists)

@blankspace(1 line)
@b(Constant :items and :components)

All aggrelists created with a constant @pr(:items) slot have a constant
@pr(:components) slot automatically.  That is, after the
aggrelist has been created with all of its components according to its
@pr(:items) list, the @pr(:components) slot becomes constant by
default, and the items and components become unmodifiable (with the
two exceptions below).  In addition, the @pr(:head) and @pr(:tail)
slots of the aggrelist, which point to the first and last component,
also become constant.  By declaring these slots constant, Garnet is
able to automatically get rid of the greatest number of formulas possible.

If you really want to add another item to a constant aggrelist, you
could wrap a call to @pr(add-item) in @pr(with-constants-disabled),
which disables the protective constant mechanism, and is described
fully in the KR Manual.  However, just as with aggregadgets (discussed
in section @ref[constants-and-aggregadgets]), this is discouraged
due to the likelihood that the dimension formulas of the aggrelist
will have already been evaluated and thrown away before the new item
is added, resulting in an incorrect bounding box for the aggrelist.

A better solution is to create a non-constant aggrelist to begin with.
If you plan to change the @pr(:items) slot, then do not include it in the
@pr(:constant) list.  If you are using T in the constant list, be sure
to @pr(:except) the @pr(:items) slot.

@blankspace(2 lines)
@b(Constant :left and :top in Components)

The @pr(:left) and @pr(:top) slots of each component are set during the
layout of the aggrelist.  If all of the slots controlling the layout are
constant in the aggrelist, then the @pr(:left) and @pr(:top) slots of the
components will be declared constant after they are set.  The slots controlling
the layout are:

@blankspace(1 line)
@Begin(Text, columns = 4, columnmargin = 0.33 in, linewidth = 3.33 in,
       boxed, columnbalance=on, size=10, spread=-1, indent=4, FaceCode T)
:left

:top

:items

:direction

:v-spacing

:h-spacing

:indent

:v-align

:h-align

:fixed-width-p

:fixed-height-p

:fixed-width-size

:fixed-height-size

:rank-margin

:pixel-margin
@end(text)
@blankspace(1 line)

Even if you do not supply customized values for these slots, you will still
need to declare them constant for the desired effect.  They are all included
in the aggrelist's @pr(:maybe-constant) list, so it is easy to declare them
all constant with a @pr(:constant) value of T.

Since the aggrelist layout function sets the @pr(:left) and @pr(:top) slots
of each component, it is important @u(not) to declare these slots constant
yourself, unless you do so after the aggrelist has already been laid out.


@paragraph(A Simple Aggrelist Example)
@label(aggitem-expl-ref)
The following code is a short example of an itemized aggrelist
composed of text strings, and the picture of this aggrelist is in
figure @ref(aggitem-expl-pict).  Note that the @pr(:left) and
@pr(:top) slots of the @pr(:item-prototype) have been left undefined.
The aggrelist will fill these slots with the appropriate values
automatically. 

@begin(programexample)
(create-instance 'MY-AGG opal:aggrelist
   (:left 10) (:top 10)
   (:direction :horizontal)
   (:items '("This" "is" "an" "example"))
   (:item-prototype
    `(,opal:text
      (:string ,(formula '(nth (gvl :rank) (gvl :parent :items)))))))
@end(programexample)

@begin(figure)
@center{@graphic(PostScript="aggregadgets/agg-list-item.PS",
                BoundingBox=file,magnify=.75)}
@caption(The picture of an itemized aggrelist.)
@tag(aggitem-expl-pict)
@end(figure)


@paragraph(An Aggrelist with an Interactor)
As another example of an itemized aggrelist, consider the schema
FRAMED-TEXT-LIST defined in figure @ref(framed-text-list).  
A picture of the FRAMED-TEXT-LIST aggrelist appears in figure
@ref(framed-text-list-pix).

@begin(figure)
@begin(programexample)
(create-instance 'FRAMED-TEXT-LIST opal:aggrelist
   (:left 0) (:top 0)
   (:items '("An aggrelist" "using an" "aggregate" 
	     "as an" "item-prototype"))
   (:item-prototype
    `(,opal:aggregadget
      (:parts
       ((:frame ,opal:rectangle
	   (:left ,(o-formula (gvl :parent :left)))
	   (:top ,(o-formula (gvl :parent :top)))
	   (:width ,(o-formula (+ (gvl :parent :text :width) 4)))
	   (:height ,(o-formula (+ (gvl :parent :text :height) 4))))
	(:text ,opal:text
	   (:left ,(o-formula (+ (gvl :parent :left) 2)))
	   (:top ,(o-formula (+ (gvl :parent :top) 2)))
	   (:cursor-index NIL)
	   (:string ,(o-formula
		      (nth (gvl :parent :rank)
		      (gvl :parent :parent :items)))))))
      (:interactors
       ((:text-inter ,inter:text-interactor
	   (:window ,(o-formula 
		      (gv-local :self :operates-on :window)))
	   (:feedback-obj NIL)
	   (:start-where ,(o-formula
	     (list :in (gvl :operates-on :text))))
	   (:abort-event #\control-\g)
	   (:stop-event (:leftdown #\RETURN))
	   (:final-function
	    ,#'(lambda (inter text event string x y)
		 (let ((elem (gv inter :operates-on)))
		   (change-item (gv elem :parent)
				string
				(gv elem :rank))))) ))))))
@end(programexample)
@caption[An aggrelist using an aggregadget as the @pr(:item-prototype).]
@tag(framed-text-list)
@end(figure)

@begin(figure)
@Center[@graphic(Postscript="aggregadgets/framed-text-list-pix.PS",boundingbox=File,magnify=.75)]
@caption(A picture of the FRAMED-TEXT-LIST aggrelist.)
@tag(framed-text-list-pix)
@end(figure)

This
aggrelist explicitly defines an aggregadget as the @pr(:item-prototype).
This aggregadget is similar to the FRAMED-TEXT schema defined
in figure @ref(framed-text), but there is an additional @pr(:final-function)
slot (see figure @ref(framed-text-list)).  The purpose of the
@pr(:final-function) is to keep the strings in the
@pr(:items) list consistent with the strings in the components.

Interaction works as follows:  Each item is an aggregadget with
its own @pr(text-interactor) behavior and @pr(text) component.
The cursor text @pr(:string) slot is constrained to the corresponding
element in the FRAMED-TEXT-LIST's @pr(:items) slot, but this
is a one-way constraint.
The text interactor modifies the @pr(:string) slot of the
cursor text using @pr(s-value), which leaves the formula in place,
but temporarily changes the slot value.  At this point, the @pr(:items)
slot and the cursor text @pr(:string) slots are inconsistent, and
any change to @pr(:items) would cause all @pr(:string) slot formulas
to re-evaluate, possibly losing the string data set by the interactor.
To avoid this problem, the @pr(:final-function) of the
text interactor directly sets the @pr(:items)
slot using @pr(change-item) to be consistent with the formula.  This
initiates a re-evaluation, but because all values are consistent,
no data is lost.  Furthermore, if the FRAMED-TEXT-LIST is saved
(see section @ref(write-gadget-sec)), the @pr(:items) list will have
the current set of strings, and what is written will match what is
displayed.

@begin(group)
Since the aggregadget defined here is similar to the
FRAMED-TEXT schema defined in figure @ref(framed-text), the
@pr(:item-prototype) slot definition could be replaced with
@begin(programexample)
(:item-prototype 
 `(,FRAMED-TEXT
   (:parts
    (:frame
     (:text :modify
	(:string ,(o-formula (nth (gvl :parent :rank)
				  (gvl :parent :parent :items)))))))
   (:interactors
    ((:text-inter :modify
		  (:final-function
		   ,#'(lambda (inter text event string x y)
			(let ((elem (gv inter :operates-on)))
			  (change-item (gv elem :parent)
				       string
				       (gv elem :rank))))))))))
@end(programexample)
provided that the definition for the FRAMED-TEXT schema preceded the
FRAMED-TEXT-LIST definition.

See section @ref(Menu-Aggrelist-Example) for an example of a menu
made with an itemized aggrelist.
@end(group)


@paragraph(An Aggrelist with a Part-Generating Function)
@label(multi-parts-fn)
@IndexSecondary(Primary="Part-generating functions", Secondary="Aggrelists")

Section @ref(creating-part-fn) discussed a feature of aggregadgets
that allows you to create parts of an aggregadget by specifying
part-generating functions.  This feature of aggregadgets can be
especially useful when an aggregadget is the @pr(:item-prototype) of
an aggrelist.  While the same principles hold for aggregadgets whether
they are solitary or used in aggrelists, there is a special
consideration regarding the @pr(:item-prototype-object) that warrants
further discussion.

A typical application of aggrelists that would involve a
part-generating function might specify a list of objects in its
@pr(:items) list and generate components that have those objects as
parts.  Such an application is pictured in figure @ref(esp-cards).
The @pr(:item-prototype) for this aggrelist is an aggregadget with a
part-generating function that determines its label.  The definition of
the aggrelist, along with its part-generating function appears below.

@begin(figure)
@Center[@graphic(Postscript="aggregadgets/esp-cards-pix.ps",boundingbox=File,magnify=.75)]
@caption(An aggrelist that uses a part-generating function in its
:item-prototype)
@tag(esp-cards)
@end(figure)

@begin(programexample)
(defun Get-Label-In-Aggrelist (agg)
  (let ((alist (gv agg :parent)))
    (if alist  @i[;; The item-prototype has no parent]
	(let* ((item (gv agg :item))
	       (new-label (if (schema-p item)
			      (if (gv item :parent)
				  @i[;; The item has been used already --]
				  @i[;; Use it as a prototype]
				  (create-instance NIL item)
				  @i[;; Use the item itself]
				  item)
			      (create-instance NIL opal:text
				(:string item)
				(:font (opal:get-standard-font
					:sans-serif :bold :very-large))))))
	  (s-value new-label :left
		   (o-formula (+ (gvl :parent :left)
				 (round (- (gvl :parent :width)
					   (gvl :width)) 2))))
	  (s-value new-label :top
		   (o-formula (+ (gvl :parent :top)
				 (round (- (gvl :parent :height)
					   (gvl :height)) 2))))
	  new-label)
        ;; Give the item-prototype a bogus part
        (create-instance NIL opal:null-object))))
@end(programexample)

@begin(programexample)
(create-instance 'CIRCLE-LABEL opal:circle
  (:width 30) (:height 30)
  (:line-style NIL)
  (:filling-style opal:black-fill))

(create-instance 'SQUARE-LABEL opal:rectangle
  (:width 30) (:height 30)
  (:line-style NIL)
  (:filling-style opal:black-fill))
@end(programexample)

@begin(programexample)
(create-instance 'PLUS-LABEL opal:aggregadget
  (:width 30) (:height 30)
  (:parts
   `((:rect1 ,opal:rectangle
      (:left ,(o-formula (+ 10 (gvl :parent :left))))
      (:top ,(o-formula (gvl :parent :top)))
      (:width 10) (:height 30)
      (:line-style NIL) (:filling-style ,opal:black-fill))
     (:rect2 ,opal:rectangle
      (:left ,(o-formula (gvl :parent :left)))
      (:top ,(o-formula (+ 10 (gvl :parent :top))))
      (:width 30) (:height 10)
      (:line-style NIL) (:filling-style ,opal:black-fill)))))
@end(programexample)

@begin(programexample)
(create-instance 'STAR-LABEL opal:polyline
  (:width 30) (:height 30)
  (:point-list (o-formula
		(let* ((width (gvl :width))    (width/5 (round width 5))
		       (height (gvl :height))  (x1 (gvl :left))
		       (x2 (+ x1 width/5))     (x3 (+ x1 (round width 2)))
		       (x5 (+ x1 width))       (x4 (- x5 width/5))
		       (y1 (gvl :top))         (y2 (+ y1 (round height 3)))
		       (y3 (+ y1 height)))
		  (list x3 y1  x2 y3  x5 y2  x1 y2  x4 y3  x3 y1))))
  (:line-style opal:line-2))
@end(programexample)

@begin(programexample)
(create-instance 'ALIST opal:aggrelist
  (:left 10) (:top 20)
  (:items (list CIRCLE-LABEL SQUARE-LABEL "W" PLUS-LABEL STAR-LABEL))
  (:direction :horizontal)
  (:item-prototype
   `(,opal:aggregadget
     (:item ,(o-formula (nth (gvl :rank) (gvl :parent :items))))
     (:width 60) (:height 80)
     (:parts
      ((:frame ,opal:rectangle
	       (:left ,(o-formula (gvl :parent :left)))
	       (:top ,(o-formula (gvl :parent :top)))
	       (:width ,(o-formula (gvl :parent :width)))
	       (:height ,(o-formula (gvl :parent :height))))
       (:label ,#'Get-Label-In-Aggrelist))))))
@end(programexample)

The parts-generating function Get-Label-In-Aggrelist takes into
account the aggregadget that will be generated for the
@pr(:item-prototype-object) in ALIST.  In this example, we are
concerned about reserving our label prototypes solely for use in the
visible components.  We could ignore this case, but then one of our prototypes
(like CIRCLE-LABEL) would become a component of the @pr(:item-prototype-object)
which never appears in the window.  (Additionally, problems could
arise if we destroyed the aggrelist along with its @pr(:item-prototype-object)
and still expected to use the label as a prototype).  Instead, we
specifically check if we are generating a part for the
@pr(:item-prototype-object) and return a bogus object, saving our real
labels for the visible instances. 

The gadgets that use aggrelists (like the button panels and menus) all
use this feature, so you can have Garnet objects in the @pr(:items)
list of a gadget.  See the Gadgets manual for further details.


@subsection(Non-Itemized Aggrelists)
@label(non-itemized-sec)
@index(parts in aggrelists)
Non-itemized aggrelists may be specified with the @pr(:parts) slot,
just as in aggregadgets, except aggrelists will automatically set the
@pr(:left) and @pr(:top) slots (among others).  Figure @ref(parts-list-fig)
creates an aggrelist with three components, and a picture of this
aggrelist is shown in figure @ref(agglist-expl-ref).

@begin(figure)
@begin(programexample)
(create-instance 'MY-AGG opal:aggrelist 
  (:left 10) (:top 10)
  (:parts
   `((:obj1 ,opal:rectangle (:width 60) (:height 30))
     (:obj2 ,opal:oval (:width 60) (:height 30))
     (:obj3 ,opal:roundtangle (:width 60) (:height 30)))))
@end(programexample)
@caption(Example of an aggrelist with a parts slot.)
@tag(parts-list-fig)
@end(figure)

@begin(figure)
@center{@graphic(PostScript="aggregadgets/agg-list.PS",BoundingBox=file,magnify=.75)}

@caption(The picture of an aggrelist with three components.)
@tag(agglist-expl-pict)
@end(figure)

Instances of aggrelists are similar to instances of aggregadgets except
for the handling of default components and the @pr(:item-prototype-object)
slot.  Unlike aggregadgets, components that were generated by a
@pr(:parts) list are not automatically inherited, so an aggrelist with
an empty @pr(:parts) slot will @i(not) inherit the parts of its
prototype.  The only way to inherit these components is to 
name them in the prototype and to list each name as one of the instance's
@pr(:parts).  For example, the following instance of MY-AGG (defined
above) will inherit the parts defined in the prototype:
@begin(programexample)
(create-instance 'MY-INST MY-AGG
  (:left 100)
  (:parts '(:obj1 :obj2 :obj3)))
@end(programexample)

Note that this syntax is consistent with the rules for customizing the
parts of aggregadgets described in section @ref(agg-insts).

@index(constants in aggrelists)
Like aggregadgets, aggrelists created with a @pr(:parts) slot
have constant @pr(:components) by default.  To cause the @pr(:left) and
@pr(:top) slots of the components to become constant after the aggrelist
is laid out, all of the layout parameters listed in section
@ref(constants-in-aggrelists) (including the @pr(:items) slot) must be declared
constant.


@section(Instances of Aggrelists)
@label(modify-item-sec)
When an instance is made of an itemized aggrelist,
components are automatically created as instances of the item prototype
object according to the local or inherited @pr(:items) slot.

A consequence of these rules for making instances is that a default instance
of a non-itemized aggrelist will typically have no components, while a default
instance of an itemized aggrelist will typically have the same component
structure as its prototype due to the inherited @pr(:items) slot.

@subsection(Overriding the Item Prototype Object)
For itemized aggrelists, an instance of the item prototype object is made
automatically and stored in the @pr(:item-prototype-object) slot of the
instance aggrelist.  The same syntax used in the @pr(:parts) slot can be
used to override slots of the item prototype object.  For example, figure
@ref(modify-item-fig) illustrates a variation on the text list in figure
@ref(framed-text-list).  Here, the @pr(:frame) component is inherited and
modified to be gray and relatively wider than its prototype, a new
component, @pr(:white-box) is added, and the @pr(:text) component is
inherited and modified to be centered in the new larger surrounding
@pr(:frame).  The text interactor is inherited without modification by
default.  

@p(Note:) The @pr(:items) list, if left unspecified, would be shared
with FRAMED-TEXT-LIST.  It is generally a good idea to specify
the @pr(:items) to avoid sharing.

@begin(figure)
@Center[@graphic(Postscript="aggregadgets/boxed-text-list-pix.PS",
	boundingbox=File,magnify=.75)]
@begin(programexample)

(create-instance 'BOXED-TEXT-LIST FRAMED-TEXT-LIST
   (:items '("An aggrelist" "using an" "inherited"
	     "but modified" "item-prototype"))
   (:left 120)
   (:top 0)
   (:item-prototype
    `(:modify
      (:parts
       ((:frame :modify
	   ; make the frame gray
	   (:filling-style ,opal:gray-fill)
	   ; make the frame wider
	   (:width ,(o-formula (+ (gvl-sibling :text :width) 16)))
	   ; make the frame taller
	   (:height ,(o-formula (+ (gvl-sibling :text :height) 16))))
	(:white-box ,opal:rectangle
	   (:filling-style ,opal:white-fill)
	   (:left ,(o-formula (+ (gvl :parent :left) 4)))
	   (:top ,(o-formula (+ (gvl :parent :top) 4)))
	   (:width ,(o-formula (+ (gvl-sibling :text :width) 8)))
	   (:height ,(o-formula (+ (gvl-sibling :text :height) 8))))
	(:text :modify  ; move the text to allow for the border
	   (:left ,(o-formula (+ (gvl :parent :left) 8)))
	   (:top ,(o-formula (+ (gvl :parent :top) 8)))))))))
@end(programexample)
@caption[An aggrelist that overrides parts of an inherited
@pr(:item-prototype).  The prototype FRAMED-TEXT-LIST was defined in
figure @ref(framed-text-list).]
@bar()
@tag(modify-item-fig)
@end(figure)

@section(Manipulating Gadgets Procedurally)

A collection of functions is available to alter aggregadget and
aggrelist prototypes.  When the prototype is altered, the changes
propagate down to instances of the prototype.  Inheritance of slots
is a standard feature of KR, but inheritance of structural changes
is unique to aggregadgets and aggrelists and is implemented by
the functions and methods described in this chapter.

The philosophy behind structural inheritance is simply stated:
@i(changing a prototype and then making an instance should be
equivalent to making an instance and then changing the prototype.)
In practice, this equivalence is difficult to achieve completely;
exceptions will be noted.

@subsection(Copying Gadgets)
@index(copy-gadget)
@pr(opal:Copy-Gadget) @i(gadget)@value(function)

This function copies an aggregadget, aggrelist, aggregate, or Opal graphical
object.  The copy will have the same structure as the original.  This is
different from (and more expensive than) creating an instance because 
nothing will be inherited from the original.

When copying an itemized aggrelist, components are not copied, because they
inherit from the local items-prototype-object.  Instead, the @pr(:items) 
slot and the item-prototype-object are copied, and new components are generated
accordingly.


@begin(group)
@subsection(Aggregadget Manipulation)
@paragraph(Add-Component)
@label(add-component-sec)

@blankspace(1 line)
@index(add-component)
@pr(opal:Add-Component) @i(gadget) @i(element) [[@pr(:where)] @i(position) [@i(locator)]]@value(method)
@end(group)
@blankspace(1 line)

This function behaves just like the @pr(add-component) method for
aggregates (see the @i(Opal Reference
Manual)) except that, 
@begin(itemize)
if @i(gadget) is a prototype, then instances of
@i(element) are also added to instances of @i(gadget).  This is recursive
so that instances of instances, etc., are also affected;

if @i(element) has slot @pr(:known-as) with value @i(name), then the
@i(name) slot of @i(gadget) is set to be @i(element).  This creates
the standard link from @i(gadget) to @i(element) (see Section
@ref(known-as-sec)).  Ordinarily, the @pr(:known-as) slot of @i(element)
should be set before calling @pr(add-component).
@end(itemize)

@p(Note:)  Names of components and interactors
must be unique within their parent.  For
example, there must not be two components named @pr(:box).

The
@i[position] and @i[locator] arguments can be used to adjust the
placement of @i[graphical-object] with respect to the rest of the
components of @i[gadget].

@i[position] can be any of these five values:
@begin(format) @tabset(0.5 in, 1.3 in, 2.1 in, 2.9 in, 3.7 in)
@\@pr(:front) @\@pr(:back) @\@pr(:behind) @\@pr(:in-front) @\@pr(:at)
or any of the following aliases:
@\@pr(:tail) @\@pr(:head) @\@pr(:before) @\@pr(:after) @\@pr(:at)
@end(format)

The keyword @pr(:where) is optional; for example, 
@begin(programexample)
(add-component aggrelist new-component :where :head)

(add-component aggrelist new-component :head)
@end(programexample)
are valid and equivalent calls to @pr(add-component).
The default value for @pr(:where) is @pr(:tail)
(add to the end of the list, which is graphically 
on top or at the front).

If @i(position) is either @pr[:before]/@pr[:behind] or
@pr[:after]/@pr[:in-front] 
then the value of @i[locator] should be a graphical object already in the
component list of the aggregate, in which case @i[graphical-object] is placed
with respect to @i[locator].

If @i[position] is @pr[:at], @i[graphical-object] is placed at the
@i[locator]th position in the component list, where
the zeroth position is the head of the list.

@p(Note:) The @pr(add-component) method will always add the component at
the most reasonable position if the specified location does not exist.
For example, if @pr(add-component) is asked to add a component after another
one that does not exist, the new component will be added at the tail.

Instances of @i(element) are created and added to instances of @i(gadget)
using recursive calls to @pr(add-component).  Since instances of
@i(gadget) may not have the same structure as @i(gadget), 
it is not always obvious where to add a component.
In particular, a given @i(locator) object will never exist
in instances, so a new instance @i(locator) must be inferred from
the prototype @i(locator) as follows:
@begin(itemize)
If the instance gadget has a component that is an instance of the
prototype @i(locator), then that component is the instance @i(locator).

Otherwise, if the instance gadget has a component with the same
@i(name) (@pr(:known-as)) as the prototype @i(locator), then that
component is the instance @i(locator).

Otherwise, a warning is printed, and there is no locator.
@end(itemize)

Given this procedure for finding an instance @i(locator),
the insert point is determined as follows:
@begin(itemize)
The default position is @pr(:front).

If the @i(position) is specified as @pr(:front) or @pr(:tail), always insert
the component at the @pr(:front).

If the @i(position) is specified as @pr(:back) or @pr(:head), always insert
the component at the @pr(:back).

If the @i(position) is @pr(:behind) or @pr(:before) @i(locator), and
an instance @i(locator) is found, then insert @pr(:behind) the instance
@i(locator), otherwise insert at the @pr(:front) (the rationale here
is to err toward the front, making errors immediately visible).

If the @i(position) is @pr(:in-front) or @pr(:after) @i(locator), and
an instance @i(locator) is found, then insert @pr(:in-front) of the instance
@i(locator), otherwise insert at the @pr(:front).

If the @i(position) is @pr(:at), then @i(locator) is an index.  Use
the same index to insert an @i(element) instance in each @i(gadget)
instance.
@end(itemize)

@paragraph(Remove Component)
@label(remove-component-sec)

@index(remove-component)
@pr(opal:Remove-Component) @i[gadget element] [ @i(destroy?) ]@value[Method]

The @pr[remove-component] method removes the
@i[element] from @i[gadget].  If @i{gadget} is connected to
a window, then @i{element} will be erased when the
window next has an update message sent to it.


Because aggregadgets allow
even the prototype of a component to be overridden in an instance,
determining what components to remove is not always straightforward.
First, @pr(remove-component) removes all instances of @i(component)
from their parents @i(if) the parent @pr(is-a-p) the @i(gadget) argument.
(This avoids breaking up aggregates that use instances of components but
which are not instances of @i(gadget).)  Then, @pr(remove-component)
removes all parts of instances of @i(gadget)
that have a @pr(:known-as) slot that matches that of
the @i(component).  Components are removed with recursive calls to 
@pr(remove-component) to affect the entire instance tree.

If @i(destroy?) is not NIL (the default is NIL), then the removed objects
are destroyed.


@paragraph(Add-Interactor)
Interactors can be added by calling

@index(add-interactor)
@pr(opal:Add-Interactor) @i(gadget) @i(interactor)@value(method)

where @i(gadget) is an aggregadget or aggrelist.  If the
interactor has a @pr(:known-as) slot, then this becomes the
name of the interactor.  The @pr(:operates-on)
slot in the interactor is set to the gadget.

An instance of @i(interactor) is added to each instance of
@i(gadget) using a recursive call to @pr(add-interactor).

@p(Note:) @i(gadget) should not have an interactor or component
with the same name (@pr(:known-as) slot) already.  Otherwise,
an inconsistent gadget will result.


@paragraph(Remove-Interactor)
@index(remove-interactor)
@pr(opal:Remove-Interactor) @i(gadget) @i(interactor) [@i(destroy?)]@value(method)

is used to remove an interactor.  The interactor @pr(:operates-on)
slot is destroyed, as is the link from @i(gadget) to the @i(interactor)
(determined by the value of the @i(interactor)'s @pr(:known-as) slot).
In addition, the @i(interactor)'s @pr(:active) slot is set to NIL.
The @i(interactor) is also destroyed if the optional @i(destroy?) 
parameter is not NIL.

Instances of @i(interactor) that belong to instances of @i(gadget)
(as determined by the @pr(:operates-on) slot) are recursively
removed.
As with @pr(remove-component),
interactors that have the same name as @i(interactor)
are removed from instances of @i(gadget).  (This will only have
an effect if, in an instance of @i(gadget), the default inherited
interactor has been overridden or replaced by a different one.)

@p(Note:) Since a call to @pr(remove-interactor) will deactivate
the interactor, be sure to set the @pr(:active) slot appropriately if
the interactor is subsequently added to a gadget.

@paragraph(Take-Default-Component)
@index(take-default-component)
@pr(opal:Take-Default-Component) @i(gadget) @i(name) [@i(destroy?)]@value(method)

This function removes a local component named by @i(name), e.g. @pr(:box),
and replaces it with an instance of the corresponding component in
@i(gadget)'s prototype.  The removed component is destroyed if and only if
the optional @i(destroy) argument is not NIL.

The placement of the new component is inherited as well as the component
itself.  As with @pr(add-component), ``inherited position'' is not
well defined when the structure of @i(gadget) does not match
the structure of its prototype.  The algorithm for choosing the
position is as follows:
If the prototype component is the first one, then the instance
becomes the first component of @i(gadget).  Otherwise, a locator (see
@pr(add-component)) is found
in the prototype such that the locator is ``@pr(:in-front)'' of the
prototype component.  If this locator has an instance in @i(gadget), 
the instance is used as a locator in a
call to @pr(add-component), with the @i(position) parameter being
@pr(:in-front).  If the locator does not exist in @i(gadget), then the
@i(position) used is @pr(:front), so at least any error should become
visibly apparent.

Changes are propagated to instances of @i(gadget).

@subsection(Itemized Aggrelist Manipulation)

@paragraph(Add-Item)
@Index(add-item)
@pr(opal:Add-Item) @i{aggrelist} [@i{item}] [[@pr(:where)] @i[position] [@i{locator}] [@pr(:key) @i{function-name}]] @value(method)

If supplied, @i(item) will be added to the @pr(:items) slot of
@i(aggrelist), and a new instance of @pr(:item-prototype-object) will
be added to the components of @i(aggrelist).  The @pr(add-item) method will
perform the necessary bookkeeping to maintain the appearance of the list.

It is an error (actually, a continuable break condition) to add an
item to an aggrelist whose @pr(:items) slot is constant.  To work around
this error, consult section @ref(constants-and-aggregadgets).

The @i[position], @i[locator] and @i[function-name] arguments can be used to 
adjust the
placement of @i[item] with respect to the rest of the items
of @i[aggrelist].

@i[position] can be any of these five values:
@begin(format) @tabset(0.5 in, 1.3 in, 2.1 in, 2.9 in, 3.7 in)
@\@pr(:front) @\@pr(:back) @\@pr(:behind) @\@pr(:in-front) @\@pr(:at)
or any of the following aliases:
@\@pr(:tail) @\@pr(:head) @\@pr(:before) @\@pr(:after) @\@pr(:at)
@end(format)
@p(Note:) the graphically @i(front) object is at the @i(tail) of the
components list, etc.
If position is either @pr[:before]/@pr[:behind] or @pr[:after]/@pr[:in-front]
then the value of @i[locator] should be an item already in the
@pr(:items) slot of the aggrelist, in which case @i[item] is placed
with respect to @i[locator].

For example, the following line will add a new item to the aggrelist
defined in section @ref(aggitem-expl-ref):
@begin(prexample)
(opal:add-item MY-AGG "really" :after "is")
@end(prexample)
The string "really" will be added to @pr(my-agg) with the resulting
aggrelist appearing as "This is really an example".

Furthermore, if the @pr(:items) slot holds a nested list, @i(:key
function-name) can be used to match @i(locator) only with the result
of @i(function-name) applied to each element of @pr(:items).
For example, if the @pr(:items) slot of @pr(an-aggrelist) is
@pr[(("foo" 4) ("bar" 2) ("foo" 7))],
@begin(programexample)
(add-item an-aggrelist '("foobar" 3) :after "foo" :key #'car)
@end(programexample) will
compare "foo" only to the @pr(car)s of the list, and therefore will add
the new item as the second element of the list.  The line
@begin(programexample)
(add-item an-aggrelist '("barfoo" 5) :before 7 :key #'cadr)
@end(programexample)
will add the new item just before the last one.

@p(Note:) @pr(add-item) will add the item at the most reasonable position
if the specified position does not exist.  For example, if
@pr(add-item) is asked to add a component after another 
one that does not exist, the new component will be added at the tail.

@paragraph(Remove-Item)
@Index(remove-item)
@pr(opal:Remove-Item) @i{aggrelist} [@i{item} [@pr(:key) @i{function-name}]] @value(Method)

The method @pr[remove-item] removes @i[item] from the @pr(:items) list and
the @pr(:components) list of @i[aggrelist].

It is an error (actually, a continuable break condition) to add an
item to an aggrelist whose @pr(:items) slot is constant.  To work around
this error, consult section @ref(constants-and-aggregadgets).

If the @pr(:items) slot holds a nested list, @i(:key function-name)
can be used to specify to try to match @i(item) only with the result
of @i(function-name) applied to each element of @pr(:items).
For example, if the @pr(:items) slot of @pr(an-aggrelist) is
@pr[(("foo" 4) ("bar" 2) ("foo" 7))],
@begin(programexample)
(remove-item AN-AGGRELIST "foo" :key #'car)
@end(programexample)
removes the first item, while
@begin(programexample)
(remove-item AN-AGGRELIST '("foo" 7))
@end(programexample)
removes the last one.

@paragraph(Remove-Nth-Item)
@index(remove-nth-item)

@pr(opal:Remove-Nth-Item) @i(aggrelist) @i(n)@value(method)

To remove an item by position rather than by content, use
@pr(remove-nth-item).  The @i(n)@+(th) item is removed from
the @pr(:items) slot of @i(aggrelist), and the component corresponding
to that item will be removed during the next call to @pr(opal:update).

It is an error to add an
item to an aggrelist whose @pr(:items) slot is constant.  To work around
this error, consult section @ref(constants-and-aggregadgets).


@Paragraph(Change-Item)
@index(change-item)

To change just one item in the @pr(:items) list, call

@index(change-item)
@pr(opal:Change-Item) @i(aggrelist item n)@value(method)

where @i(aggrelist) is the aggrelist to be modified, @i(item) is a
new value for the @pr(:items) list, and @i(n) is the index of the 
item to be changed (the index of the first item is zero).

This function is potentially more efficient than calling @pr(add-item) and
@pr(remove-item), because it ensures that the component corresponding to the
changed item will be reused if possible, instead of destroying and reallocating
a new component.


@paragraph(Replace-Item-Prototype-Object)
@index(replace-item-prototype-object)

@pr(opal:Replace-Item-Prototype-Object) @i(aggrelist) @i(item-proto)@value(method)

This function is used to replace the @pr(:item-prototype-object) slot of
an itemized aggrelist.  Any aggrelists which inherit
the slot from this one will also be affected.  The components of affected
aggrelists are replaced with instances of the new
@pr(:item-prototype-object).

For example, suppose an application uses a number of instances
of  radio buttons,
an aggrelist whose item prototype object
determines the appearance of a single button.  By calling
@pr(replace-item-prototype-object) on the radio buttons prototype,
all button throughout the application will change to reflect the
new style.

@subsection(Ordinary Aggrelist Manipulation)
@label(aggrelist-manipulation-sec)

@paragraph(Add-Component)
@Index(add-component)

The @pr(add-component), defined in section @ref(add-component-sec) can also
be used to add components to an aggrelist.  The system automatically adjusts
the appearance of the aggrelist to accommodate the changes in the list of
components.

In addition to adding @i(graphical-object) to @i(aggrelist),
@pr(add-component) will add some slots to @i(graphical-object), or modify
existing slots.  The slots created or modified by @pr(add-component) are:

@begin(description, leftmargin=10, indent=-6)
@pr(:left, :top) @value(shortdash) Unless the @pr(:direction) slot of
@i(aggrelist) is NIL, the system will set these slots with integers that
arrange @i(graphical-object) neatly in the layout of the aggrelist components.

@pr(:rank) @value(shortdash) This slot is set with a number that indicates
the position of this component in the list (the head has rank 0).  If this
component is not visible, then this value has no meaning.

@pr(:prev) @value(shortdash) This contains the previous component in the list,
regardless of what is visible.

@pr(:next) @value(shortdash) This contains the next component in the list,
regardless of what is visible.

@end(description)

@p(Note:) @pr(add-components) (plural) can be used to add several
components to an aggrelist.

An alternative implementation of figure @ref(parts-list-fig) is shown in
figure @ref(agglist-expl-ref).  In each component of the aggrelist, the
@pr(:left) and @pr(:top) slots have been left undefined.  The aggrelist will
fill these slots with the appropriate values automatically.

@begin(figure)
@begin(programexample)
(create-instance 'MY-AGG opal:aggrelist (:top 10) (:left 10))
(create-instance 'MY-RECT opal:rectangle
   (:width 100) (:height 30))
(create-instance 'MY-OVAL opal:oval
   (:width 100) (:height 30))
(create-instance 'MY-ROUND opal:roundtangle
   (:width 100) (:height 30))
(add-components MY-AGG MY-RECT MY-OVAL MY-ROUND)
 
@end(programexample)
@caption(Example of an aggrelist built using add-component.)
@tag(agglist-expl-ref)
@end(figure)


@paragraph(Remove-Component)

See section @ref(remove-component-sec) for a description of this method.

@Index(null-object)
@b(Useful hint:) It is possible to make components of an aggrelist 
temporarily disappear by simply
setting their @pr(:visible) slot to NIL @Y[N] the list will adjust itself so
that there is no gap where the item once was.  If a gap is desired, then an
@pr(opal:null-object) may be inserted into the list @Y[N] this is an
@pr(opal:view-object) that has its @pr(:visible) slot set to T, but has no
draw method.


@paragraph(Remove-Nth-Component)
@index(remove-nth-component)

@blankspace(1 line)
@pr(opal:Remove-Nth-Component) @i(aggrelist n)@value(method)

The @i(n)@+(th) component of @i(aggrelist) is removed by
invoking @pr(remove-local-component).  Instances of @i(aggrelist)
are @i(not) affected.


@subsection(Local Modification)
A number of functions exist to modify gadgets without changing their
instances.  Their behavior is exactly like the corresponding
recursive version described earlier, except that changes are
not propagated to instances.

@index(add-local-component)
@pr(opal:Add-Local-Component) @i(gadget) @i(element) [[@pr(:where)] @i(position) [@i(locator)]]@value(method)

@index(remove-local-component)
@pr(opal:Remove-Local-Component) @i[gadget element] [ @i(destroy?) ]@value[Method]

@index(add-local-interactor)
@pr(opal:Add-Local-Interactor) @i(gadget) @i(interactor)@value(method)

@index(remove-local-interactor)
@pr(opal:Remove-Local-Interactor) @i(gadget) @i(interactor) [@i(destroy?)]@value(method)

@Index(add-local-item)
@pr(opal:Add-Local-Item) @i{aggrelist} [@i{item}] [[@pr(:where)] @i[position] [@i{locator}] [@pr(:key) @i{function-name}]] @value(method)

@Index(remove-local-item)
@pr(opal:Remove-Local-Item) @i{aggrelist} [@i{item} [@pr(:key) @i{function-name}]] @value(Method)


@section(Reading and Writing Aggregadgets and Aggrelists)
@index(write-gadget)@index(saving aggregadgets)
An aggregadget or aggrelist may be written to a file.  This creates
a compilable lisp program that can be reloaded to recreate the object
that was saved.  To save an aggregadget, use the @pr(opal:write-gadget)
function:

@subsection(Write-Gadget)
@label(write-gadget-sec)

@blankspace(1 line)
@index(write-gadget)
@pr(opal:Write-Gadget) @i(gadget) @i(file-name) &optional @i(initialize?)@value(function)

where @i(gadget) is a graphical object, an
aggregadget or an aggrelist (or a list of these), and @i(file-name)
is the file name (a string) to be written, or @pr(t) to write
to @pr(*standard-output*).  If several calls are made to @pr(write-gadget)
to output a sequence of
gadgets to the same stream, set the @i(initialize?) flag
to NIL after the first call.  The default value of @i(initialize?) is T.

If the gadget has any references to
gadgets that are not part of the standard set of Opal objects or
Interactors, then a warning is printed.   @p(Note:) @i(gadget)
must not be a symbol or list of symbols:
@begin(programexample)
(write-gadget (list BUTTON SLIDER) "misc.lisp")  @!@i(; RIGHT!)
(write-gadget '(BUTTON SLIDER) "misc.lisp")@/@i(; WRONG!)
@end(programexample)

Slots that are ordinarily created automatically are not written
by @pr(write-gadget).  For example, the @pr(:is-a-inv) slot 
(maintained by KR) and the @pr(:update-slots-values) slot (maintained
by Opal) are not written.  The slots to ignore are found in the
@index(do-not-dump-slots)
@pr(:do-not-dump-slots) slot, which is normally inherited.  In some
cases, it may be desirable to suppress the output of certain slots,
e.g. bookkeeping information, and this can be done by setting
@pr(:do-not-dump-slots) as follows:
@begin(programexample)
(s-value @i(my-proto)
         :do-not-dump-slots
         (append @i(list-of-slots) (gv @i(my-proto) :do-not-dump-slots)))
@end(programexample)
Do not destructively modify @pr(:do-not-dump-slots)!  Putting
the slot name @pr(:do-not-dump-slots) on the list will prevent the
@pr(:do-not-dump-slots) slot from being written.  This is probably
not a good idea, since if the object is written and reloaded, the
local @pr(:do-not-dump-slots) information will be lost.

@paragraph(Avoiding Deeply Nested Parts Slots)
One would expect an instance of a standard gadget (see the @i(Garnet
Gadgets Reference Manual)) to have a very concise output representation;
however, once the instance is manipulated, various slots are set
by interactors.  Often, these slots are deeply nested in the gadget
structure, and the output has correspondingly deeply nested @pr(:parts)
slots.  This is a consequence of the fact that Garnet maintains
little separation 
between the gadget definition and local state information.  

One solution is to carefully install slot names on the
@pr(:do-not-dump-slots) slot to suppress the output of slots for
which the default inherited value is acceptable.  Another, more
drastic, solution is to set the @index(do-not-dump-objects)
@pr(:do-not-dump-objects) slot
in selected objects.  This slot may have one of three values:
@begin(itemize)
NIL @value(shortdash) The default; write out all slots and parts
that differ from the prototype.

@pr(:me)@index(me) @value(shortdash) Assume that all components and 
interactors are inherited without modification, so there is
no need to write @pr(:parts), @pr(:interactors), or @pr(:item-prototype)
slots at this level.  Other slots, such as @pr(:left) and @pr(:top)
should be written.

@pr(:children)@index(children) 
@value(shortdash) Write out @pr(:parts), @pr(:interactors)
and @pr(:item-prototype) slots, but do not allow further nesting.  This
is equivalent to setting the @pr(:do-not-dump-objects) slot of each
component, interactor, and the item-prototype to @pr(:me).
@end(itemize)

@paragraph(More Details)
The @pr(write-gadget)
function makes no attempt to write out objects that are needed
as prototypes or that are referenced by formulas.
It is the user's responsibility to make sure these objects are loaded
before loading a gadget; otherwise, an ``unbound symbol'' error is
likely to occur.
If the @i(gadget) argument is a list, then each aggregadget or aggrelist
of the list is written in sequence to the file.

To load a gadget after it has been written, the standard lisp loader
(@pr(load)) should be used.

When an aggregadget is written that uses a function to create parts
(see section @ref(run-time)), the created parts are written explicitly
and in full, as opposed to simply writing out the original @pr(:parts)
slot.  This guarantees that any modifications to the aggregadget after
it was created will be correctly written.

@index(verbose-write-gadget)
@index(*verbose-write-gadget*)
@pr(opal:*verbose-write-gadget*)@value(variable)

If @pr(*verbose-write-gadget*) is non-NIL,
objects will be printed to @pr(*error-output*)
as they are visited by @pr(write-gadget).  Indentation indicates the
level of the object in the aggregate hierarchy.  @p(Note:) objects will
be printed even if, due to inheritance, nothing needs to be written.

@paragraph(Writing to Streams)
The @pr(write-gadget) function can be used as is for simple applications,
but it is sometimes desirable to write a header to a file and perhaps
embed code written by @pr(write-gadget) into a function definition.
This is done by temporarily re-binding @pr(*standard-output*) as in the
following example:
@begin(programexample)
(with-open-file (*standard-output* "my-file.lisp"
		 :direction :output :if-exists :supersede)
    @i(;; write header to standard output:)
    (format T "... file header info goes here ...")
    @i(;; write a gadget:)
    (write-gadget my-gadget t)
    @i(;; if there are more gadgets, call with initialize? set to NIL:)
    (write-gadget another-gadget T NIL))
@end(programexample)

@paragraph(References to External Objects)
Gadgets may contain references to ``external objects'', that is,
objects that are not part of the gadget.  
When an external object is written,
A warning is ordinarily
printed  to notify the user that
the object must be present when the gadget code is loaded.

@index(standard-names)
@index(*standard-names*)
@pr(opal:*standard-names*)@value(variable)

Many objects, including standard Opal objects, standard Interactors, and 
objects in the Garnet Gadget library, are considered part of the Garnet
environment, so no warning is written for these references.  The list
@pr(*standard-names*) tells @pr(write-gadget) what object symbols to assume
will be defined when the gadget is loaded.  This list can be extended
with new new names before calling @pr(write-gadget).

@index(defined-names)@index(*defined-names*)
@pr(opal:*defined-names*)@value(variable)

The global variable @pr(*defined-names*) is initialized to 
@pr(*standard-names*)
when you call @pr(write-gadget).  As gadgets are written, their names are
pushed onto @pr(*defined-names*), so if a list of gadgets is written
and the second references the first, no warning will be printed.
@pr(*defined-names*) (not @pr(*standard-names*)) is what @pr(write-gadgets)
actually searches to see if a name is defined.  

@index(required-names)
@index(*required-names*)
@pr(opal:*required-names*)@value(variable)

The variable @pr(*required-names*) 
is initialized to NIL when you call @pr(write-gadget).
Whenever a name is written that is not on @pr(*defined-names*), it
is pushed onto @pr(*required-names*) and a warning is printed.
Inspecting the value of @pr(*required-names*) after calling
@pr(write-gadget) can give the caller information about what
additional gadgets should be saved.

The initialization of @pr(*defined-names*) and @pr(*required-names*)
is suppressed when the @i(initialize?) argument to @pr(write-gadget)
is set to NIL.


@paragraph(References to Graphic Qualities)

A reference to an @pr(opal:graphic-quality) object is handled as a 
special case.  Graphic qualities include @pr(opal:filling-style),
@pr(opal:line-style), @pr(opal:color), @pr(opal:font), and 
@pr(opal:font-from-file).  Although these are objects, they are
treated more like record structures throughout the Garnet system.
For example, changing a slot in a graphic quality will not
automatically cause an update; only replacing a graphic quality
with a new one (or faking it with a call to @pr(kr:mark-as-changed))
will cause the update.

Because of the way graphic qualities are used, it is best to
think of graphic qualities as values rather than shared objects.
Consequently, @pr(write-gadget) writes out graphic qualities
by calling @pr(create-instance) to construct an equivalent object
rather than by writing an external reference that is likely to be
undefined when the file is loaded.  

For example, here is a rectangle with a special color, and the output
generated by @pr(write-gadget):
@begin(programexample)
(create-instance 'MY-RED RED
   (:red 0.5))

(create-instance 'MY-RECT RECTANGLE
   (:color my-red))

* (write-gadget MY-RECT T)
(create-instance 'MY-RECT RECTANGLE
   (:COLOR (create-instance NIL COLOR
              (:BLUE 0.0)
	      (:GREEN 0.0)
	      (:RED 0.5))))
@end(programexample)


@paragraph(Saving References From Within Formulas)
Writing direct references from within @pr(o-formula)'s 
to other objects is not possible (in a lisp implementation-independent
way) because @pr(o-formula) builds a closure, and bindings within the
closure are not externally visible.  For example, in
@begin(programexample)
(let ((thermometer THERMOMETER-1))
  (o-formula (gv thermometer :temperature)))
@end(programexample)
the variable @i(thermometer) is bound inside the @pr(let) and is not
accessible to any routine that would write the formula.  Even though
the expression @pr[(gv thermometer :temperature)] is saved
in the formula in the current KR implementation, this does not
reveal the binding needed to reconstruct the formula.

Fortunately, 
aggregadgets and aggrelists rarely make direct references to objects.
Typically, references to objects take the form of paths in formulas,
for example, @pr[(gvl :parent :box :left)].  However, there may be
occasions when a direct reference is required, for example, when an
aggregadget depends upon the value of some separate application object.

There are several ways to avoid problems associated with direct references
from formulas:
@begin(itemize)
Use @pr(formula) instead of @pr(o-formula).  The @pr(formula) function
interprets its expression, so expressions with embedded references
can be constructed at run-time.  For example, the thermometer example
could be written as:
@begin(programexample)
(formula `(gv ',thermometer :temperature))
@end(programexample)
embedding the actual reference directly into the expression.  This
expression can be written and read back in without problems.
However, since formula expressions are interpreted, re-evaluation of the 
formula will be much slower than the corresponding o-formula.

Put the object reference into a slot, avoiding direct references altogether.
For example, to create a dependency on the @pr(:temperature) slot of object 
THERMOMETER-1, set the @pr(:thermometer) slot of the gadget to
THERMOMETER-1, and reference the slot from the formula:
@begin(programexample)
(o-formula (gvl :thermometer :temperature))
@end(programexample)
Since the reference to THERMOMETER-1 is now a slot value rather
than a hidden binding in a closure, it can be written and read back in
without problems.  The only performance penalty of this approach
will be the extra slot access, which should not add much overhead.
There is, however, the added problem of choosing slot names so as not
to interfere with other formulas.
@end(itemize)



@begin(comment)
Use an @pr(e-formula), described below.  This provides the functionality
and speed of @pr(o-formula) as well as the ability to save to files
at the expense of a little more work for the programmer and some 
extra function definitions.

@subsection(The e-formula function)
@index(e-formula)
@pr(e-formula) @i(expression)@value(function)

The argument to @pr(e-formula) is an expression that, when evaluated,
will return a formula.  The expression is retained so that the 
original @pr(e-formula) expression can be reconstructed when the
formula is written to a file.  Returning once again to the thermometer
example, here is how the problem would be solved using @pr(e-formula):
@begin(programexample)
(defun temperature-formula (thermometer)
   (o-formula (gv thermometer :temperature)))

(create-instance 'DISPLAY-1 DISPLAY
   (:value (e-formula `(temperature-formula ',THERMOMETER-1)))
@end(programexample)
The first expression defines
an auxiliary (compiled) function @pr(temperature-formula).
The second expression creates an instance of the prototype
@pr(display) (not implemented here) whose @pr(:value) slot holds
the desired formula.

When the @pr(e-formula) expression is evaluated, the argument,
@begin(programexample)
(temperature-formula '#k<THERMOMETER-1>)
@end(programexample)
is evaluated.  The @pr(temperature-formula) function in turn produces
an @pr(o-formula) in which the reference to @pr[#k<thermometer-1>] is
captured by a compiled closure.  Because the @pr(o-formula) is based
on a compiled closure, it will evaluate quickly.  Note that the
Lisp interpreter is invoked only to @i(create) the formula, not to evaluate
it.

When @pr(display-1) is written to a file, @pr(write-gadget) will
write
@begin(programexample)
(e-formula `(temperature-formula ',THERMOMETER-1))
@end(programexample)
which is the same expression used to create the original formula.
A warning will be issued when the THERMOMETER-1 is written:
@begin(programexample)
Warning: non-standard schema written as THERMOMETER-1
@end(programexample)
to warn that a direct reference to THERMOMETER-1 was written
and must be defined when the schema is reloaded.
In order to reload this formula, the function @pr(temperature-formula)
must be also be defined.
@end(comment)



@section(More Examples)

@subsection[A Customizable Check-Box]
@Label(Custom-check-box1)

Figure @ref(example-1) shows the definition of a 
check-box whose position and size can be determined by the
programmer when it is used as a prototype object.

The @pr(:parts) slot
defines the @pr(:box) object as an instance of @pr(opal:rectangle) with
coordinates dependent on the parent aggregadget.  Similarly, the @pr(:mark)
object is an @pr(opal:aggregadget) itself, and its components are dependent
on slots in the top-level aggregadget.

Two instances of CHECK-BOX are created @Y[N] the first one using the
default values for the coordinates and the second one using both default
and custom coordinates.  Both are pictured in figure
@ref(example-1-pic).

@begin(figure)
@begin(programexample)
(create-instance 'CHECK-BOX opal:aggregadget
   (:left 20)
   (:top 20)
   (:width 50)
   (:height 50)
   (:parts
    `((:box ,opal:rectangle
         (:left ,(o-formula (gvl :parent :left)))
         (:top ,(o-formula (gvl :parent :top)))
         (:width ,(o-formula (gvl :parent :width)))
         (:height ,(o-formula (gvl :parent :height))))
      (:mark ,opal:aggregadget
         (:parts
          ((:left-line ,opal:line
              (:x1 ,(o-formula (+ (gvl :parent :parent :left)
                     (floor (gvl :parent :parent :width) 10))))
              (:y1 ,(o-formula (+ (gvl :parent :parent :top)
                     (floor (gvl :parent :parent :height) 2))))
              (:x2 ,(o-formula (+ (gvl :parent :parent :left)
                     (floor (gvl :parent :parent :width) 2))))
              (:y2 ,(o-formula (+ (gvl :parent :parent :top)
                     (floor (* (gvl :parent :parent :height) 9)
			    10))))
              (:line-style ,opal:line-2))
          (:right-line ,opal:line
              (:x1 ,(o-formula 
		     (opal:gvl-sibling :left-line :x2)))
              (:y1 ,(o-formula
		     (opal:gvl-sibling :left-line :y2)))
              (:x2 ,(o-formula (+ (gvl :parent :parent :left)
                     (floor (* (gvl :parent :parent :width) 9)
			    10))))
              (:y2 ,(o-formula (+ (gvl :parent :parent :top)
                     (floor (gvl :parent :parent :height) 10))))
              (:line-style ,opal:line-2))))))))

(create-instance 'CB1 CHECK-BOX)

(create-instance 'CB2 CHECK-BOX (:left 90) (:width 100) (:height 60))
@end(programexample)
@caption[The definition of a customizable check-box.]
@tag(example-1)
@end(figure)

@begin(figure)
@center{@graphic(PostScript="aggregadgets/agg-custom-cb.ps",BoundingBox=File,magnify=.75)}

@caption(Instances of the customizable check-box.)
@tag(example-1-pic)
@end(figure)


@subsection[Hierarchical Implementation of a Customizable Check-Box]
@Label(custom-check-box2)

Figure @ref(example-2) shows the definition of a
customizable check-box as in figure @ref(example-1).  However, this
second CHECK-BOX definition exploits the hierarchical structure of the
check box to modularize the definition of the schema.  The modular style
allows for the reuse of previously defined code @Y[N] the CHECK-MARK schema
may now be used for other applications as well.

@begin(figure)
@begin(programexample)
(create-instance 'CHECK-MARK opal:aggregadget
  (:parts
   `((:left-line ,opal:line
      (:x1 ,(o-formula (+ (gvl :parent :parent :left)
			  (floor (gvl :parent :parent :width) 10))))
      (:y1 ,(o-formula (+ (gvl :parent :parent :top)
			  (floor (gvl :parent :parent :height) 2))))
      (:x2 ,(o-formula (+ (gvl :parent :parent :left)
			  (floor (gvl :parent :parent :width) 2))))
      (:y2 ,(o-formula (+ (gvl :parent :parent :top)
			  (floor (* (gvl :parent :parent :height) 9) 10))))
      (:line-style ,opal:line-2))
     (:right-line ,opal:line
      (:x1 ,(o-formula (opal:gvl-sibling :left-line :x2)))
      (:y1 ,(o-formula (opal:gvl-sibling :left-line :y2)))
      (:x2 ,(o-formula (+ (gvl :parent :parent :left)
			  (floor (* (gvl :parent :parent :width) 9) 10))))
      (:y2 ,(o-formula (+ (gvl :parent :parent :top)
			  (floor (gvl :parent :parent :height) 10))))
      (:line-style ,opal:line-2)))))

(create-instance 'CHECK-BOX opal:aggregadget
  (:left 20)
  (:top 20)
  (:width 50)
  (:height 50)
  (:parts
   `((:box ,opal:rectangle
      (:left ,(o-formula (gvl :parent :left)))
      (:top ,(o-formula (gvl :parent :top)))
      (:width ,(o-formula (gvl :parent :width)))
      (:height ,(o-formula (gvl :parent :height))))
     (:mark ,check-mark))))
@end(programexample)
@caption[A hierarchical implementation of a customizable check-box.]
@tag(example-2)
@end(figure)


@subsection(Menu Aggregadget with built-in interactor, using Aggrelists)
@Label(Menu-Aggrelist-Example)

The figure @ref(menu-aggrelist-ref) shows how to create a menu aggregadget,
by using itemized aggrelist to create the items of the menu.
This example also shows how to attach an interactor to such an object.
The menu is made of four parts: a frame, a shadow, a feedback
and an items-agg, which is an aggrelist containing the items
of the menu.  Each item is an instance of the prototype @pr(menu-item).
The items are created according to the labels and notify-functions given in
the @pr(:items) slot of the menu. The menu also contains a built-in interactor which, when
activated, will call the functions associated to the selected item.

The figure @ref(menu-aggrelist2-ref) shows how to create an instance
of the menu. A picture of these menus (the prototype and its instance)
is shown in figure @ref(menu-aggitem-pict).

@begin(figure)
@center{@graphic(PostScript="aggregadgets/agg-list-item-menu.PS",
                BoundingBox=file,magnify=.75)}
@caption[The two menus (prototype and instance) made with itemized aggrelist.]
@tag(menu-aggitem-pict)
@end(figure)

@begin(figure)
@begin(programexample)
(defun my-cut () (format T "~%Function CUT called~%"))
(defun my-copy () (format T "~%Function COPY called~%"))
(defun my-paste () (format T "~%Function PASTE called~%"))
(defun my-undo () (format T "~%Function UNDO called~%"))

(create-instance 'MENU-ITEM opal:text
   (:string (o-formula (car (nth (gvl :rank) (gvl :parent :items)))))
   (:action (o-formula (cadr (nth (gvl :rank)
				  (gvl :parent :items))))))

(create-instance 'MENU opal:aggregadget
   (:left 20) (:top 20) 
   (:items '(("Cut" (my-cut)) ("Copy" (my-copy))
             ("Paste" (my-paste)) ("Undo" (my-undo))))
   (:parts 
    `((:shadow ,opal:rectangle
	(:filling-style ,opal:gray-fill)
	(:left ,(o-formula (+ (gvl :parent :frame :left) 8)))
	(:top ,(o-formula (+ (gvl :parent :frame :top) 8)))
	(:width ,(o-formula (gvl :parent :frame :width)))
	(:height ,(o-formula (gvl :parent :frame :height))))
      (:frame ,opal:rectangle
	(:filling-style ,opal:white-fill)
	(:left ,(o-formula (gvl :parent :left)))
	(:top ,(o-formula (gvl :parent :top)))
	(:width ,(o-formula (+ (gvl :parent :items-agg :width) 8)))
	(:height ,(o-formula (+ (gvl :parent :items-agg :height) 8))))
      (:feedback ,opal:rectangle
	(:left ,(o-formula (- (gvl :obj-over :left) 2)))
	(:top ,(o-formula (- (gvl :obj-over :top) 2)))
	(:width ,(o-formula (+ (gvl :obj-over :width) 4)))
	(:height ,(o-formula (+ (gvl :obj-over :height) 4)))
	(:visible ,(o-formula (gvl :obj-over)))
	(:draw-function :xor))
      (:items-agg ,opal:aggrelist
	(:fixed-width-p T)
	(:h-align :center)
	(:left ,(o-formula (+ (gvl :parent :left) 4)))
	(:top ,(o-formula (+ (gvl :parent :top) 4)))
	(:items ,(o-formula (gvl :parent :items)))
	(:item-prototype ,menu-item))))
   (:interactors
    `((:press ,inter:menu-interactor
	(:window ,(o-formula (gv-local :self :operates-on :window)))
	(:start-where ,(o-formula (list :element-of
			(gvl :operates-on :items-agg))))
	(:feedback-obj ,(o-formula (gvl :operates-on :feedback)))
	(:final-function 
	  ,#'(lambda (interactor final-obj-over)
		(eval (gv final-obj-over :action))))))))
@end(programexample)
@caption(Definition of a menu with built-in interactor and itemized aggrelist.)
@tag(menu-aggrelist-ref)
@end(figure)

@begin(figure)
@begin(programexample)
(defun my-read () (format T "~%Function READ called~%"))
(defun my-save () (format T "~%Function SAVE called~%"))
(defun my-cancel () (format T "~%Function CANCEL called~%"))

(create-instance 'MY-MENU MENU
   (:left 100) (:top 20) 
   (:items '(("Read" (my-read)) ("Save" (my-save))
             ("Cancel" (my-cancel)))))
@end(programexample)
@caption(Creation of an instance of MENU.)
@tag(menu-aggrelist2-ref)
@end(figure)


@begin(group)
@Chapter(Aggregraphs)
@label(aggregraphs)
@index(aggregraphs)

The purpose of Aggregraphs is to allow the easy
creation and manipulation of graph objects, analogous to the
creation and manipulation of lists by Aggrelists.  In addition to the standard
@pr(aggregraph), Opal provides the @pr(scalable-aggregraph) which will fit
inside dimensions supplied by the programmer, and the
@pr(scalable-@|aggregraph-@|image) which changes appearance in response to
changes in the original graph.


@Section(Using Aggregraphs)
@index(graph-node)
@index(source-node)

In order to generate an aggregraph from a source graph, the source graph must
be described by defining its roots (a graph may have more than one root) and
a function to generate children from parent nodes.  When the
aggregraph is initialized, the generating function is first called on the
root(s), then on the children of the roots, and so on.  For each
@i(source-node) in the original graph, a new @i(graph-node) is created and
added to the aggregraph.  Graphical links are also created which connect the
graph-nodes appropriately.  The layout function (which can be specified by the
user) is then called to layout the graph in a pleasing manner.
The resulting aggregraph instance can then be displayed and manipulated
like any other Garnet object.

Although most
programmers will be satisfied with the graphs generated by the default layout
function, section @ref(layout-graph) contains a discussion of how to
customize the function used to compute the locations for the nodes in the
graph.

See the file @pr(demo-graph.lisp) for a complete interface that uses many
features of aggregraphs.
@end(group)

@Subsection(Accessing Aggregraphs)
@index(garnet-aggregraphs-loader)

The aggregraph files are @u(not) automatically loaded when the file
@pr(garnet-loader.lisp) is used to load Garnet.  There is a separate file
called @pr(aggregraphs-loader.lisp) that is used to load all the aggregraphs
files.  This file is loaded when the line
@programexample{(load Garnet-Aggregraphs-Loader)}
is executed after Garnet has been loaded with @pr(garnet-loader.lisp).

Aggregraphs reside in the @pr(Opal) package.  We recommend that programmers
explicitly reference the @pr(Opal) package when creating instances of
aggregraphs, as in @pr(opal:aggregraph).  However, the package name may be
dropped if the line
@programexample{(use-package 'opal)}
is executed before referring to any object in that package.


@Subsection(Overview)
@index(children-function)
@index(info-function)
@index(source-roots)

In general, programmers will be able to ignore most of the aggregraph slots
described in the following sections, since they are used to customize the
layout function of the aggregraph.  However, three slots must be set before
before any aggregraph can be initialized:

@begin(itemize)
@pr(:children-function) -- This slot should contain a function that generates
a list of child nodes from a parent node.  The function takes the parameters
@programexample[(lambda (source-node depth))]
where @i(depth) is a number maintained internally by aggregraphs that
corresponds to the distance of the current node from the root,
and @i(source-node) is an
object in the source graph to be expanded.  The function should return a list
of the children of @i(source-node) in the source graph, or NIL to indicate the
node either has no children or should not be expanded (when depth > 1, for
example).

@pr(:info-function) -- The function in this slot should take the parameter
@programexample[(lambda (source-node))]
where @i(source-node) is an object in the source graph.  It should return a
string associated with the @i(source-node) so that a label can be placed on
its corresponding graph node in the aggregraph.  (If the node-prototype is
customized by the programmer, then this function might return some other
identifying object instead of a string.)  The value returned by the function
is stored in the @pr(:info) slot of the graph node.

@pr(:source-roots) -- A list of roots in the source graph.
@end(itemize)

@b(Caveats:)

The source nodes must be distinguishable by one of the tests
@pr(#'eq), @pr(#'eql), or @pr(#'equal).  The default is @pr(#'eql).
(Refer to the @pr[:test-to-distinguish-source-nodes] slot in section
@ref[aggregraph-slots].)

Instances of aggregraphs can be used as prototypes for other aggregraphs
without providing values for all the required slots in the prototype.


@Subsection(Aggregraph Nodes)
@label(node-slots)
@index(node)
@index(graph-node)
@index(node-prototype)
@index(link-prototype)

Each type of aggregraph has its own type of node and link prototypes.  For the
@pr(aggregraph), the prototypes are @pr(aggregraph-node-prototype) and
@pr(aggregraph-link-prototype), which are defined in the slots
@pr(:node-prototype) and @pr(:link-prototype).  To change the look of the nodes
or the links in an aggregraph, the programmer will need to define new
prototype objects in these slots.  Section @ref(aggregraph-with-interactor)
contains an example aggregraph schema that modifies the node prototype.

The node and link prototypes for @pr(scalable-aggregraph) are
@pr(scalable-@|aggregraph-@|node-prototype) and
@pr(scalable-@|aggregraph-@|link-prototype).  The prototypes for
@pr(scalable-@|aggregraph-@|image) are
@pr(scalable-@|aggregraph-@|image-@|node-prototype) and
@pr(scalable-@|aggregraph-@|image-@|link-prototype).

The actual nodes and links of the aggregraph are kept in "sub-aggregates" of
the aggregraph.  The aggregates in the @pr(:nodes) and @pr(:links) slots of
the top-level aggregraph have the nodes and links as their components.  To
access the individual links and nodes, look at the
@pr(:components) slot of these aggregates.  For example, the instruction
@begin(programexample)
(opal:do-components (gv graph :nodes)
                    #'(lambda (node)
                        (format T "~A~%" (gv node :info))))
@end(programexample)
will print out the names of all the nodes in the graph.

@index(back-pointer)
As each graph-node is created, a pointer to the corresponding
source-node is put in the slot @pr(:source-node) of the graph-node.
This allows access to the source node from the graph-node.  If
desired, a user can supply a function in the slot
@pr(:add-back-pointer-to-nodes-function).  This function will be called on each
source-node/graph-node pair, and should put a pointer to the
graph-node in the source-node data structure.  This can be used to
establish back pointers in the programmer's data structure.

The function in the slot @pr(:source-to-graph-node) can be useful in finding
a particular node in the graph.  When this method is given a source-node, it
will return the corresponding graph-node if one already exists in the graph.


Useful slots in the node objects include:

@begin(description, leftmargin=10, indent=-6)

@pr(:left) and @pr(:top) -- These slots must be set either directly by the
layout function or indirectly through formulas (probably dependent on other
slots in the node that are set by the layout function).

@pr(:width) and @pr(:height) -- Dimensions of the node.

@pr(:links-to-me) and @pr(:links-from-me) -- Each slot contains a list of
links that point to or from the given node.  To get the nodes on the other side
of the links, reference the @pr(:from) and @pr(:to) slots of the links,
respectively.

@pr(:source-node) -- A pointer to the corresponding node in the source graph
(i.e., the source-node of this graph-node).  See
@pr(:add-@|back-@|pointer-@|to-@|nodes-@|function) for back-pointers from the
source-node to the graph-node.

@pr(:layout-info-...) -- Several slots that begin with "@pr(:layout-info-)"
are reserved for bookkeeping by the layout function.  Do not set these slots
except as part of a customized layout function.

@end(description)



@begin(group)
@Subsection(A Simple Example)
@blankspace(1 line)

@begin(programexample)
(create-instance 'SCHEMA-GRAPH opal:aggregraph
   (:children-function #'(lambda (source-node depth)
			   (if (> depth 1)
			       NIL
			       (gv source-node :is-a-inv))))
   (:info-function #'(lambda (source-node)
		       (string-capitalize
			(kr:name-for-schema source-node))))
   (:source-roots (list opal:view-object)))
@end(programexample)
@end(group)

@begin(figure)
@Center[@graphic(Postscript="aggregadgets/schema-graph.ps",boundingbox=File,magnify=.75)]
@caption(Graph generated by SCHEMA-GRAPH)
@tag(schema-graph-pix)
@end(figure)

The graph pictured in figure @ref(schema-graph-pix) is a result of the
definition of the SCHEMA-GRAPH object above.  The aggregraph was given
a description of the Garnet inheritance hierarchy just by defining the root
of the graph and a child-generating function.

The generating function in the @pr(:children-function) slot is defined to
return the instances of a given schema until the aggregraph reaches a certain
depth in the graph.  In this case, if the function is given a node that is
more than one link away from the root, then the function will return NIL.

The function in the @pr(:info-function) slot returns the string name of
a Garnet schema.


@begin(group)
@Subsection(An Example With an Interactor)
@label(aggregraph-with-interactor)
@blankspace(1 line)

@begin(programexample)
(create-instance 'SCHEMA-GRAPH-2 opal:aggregraph
   (:children-function #'(lambda (source-node depth)
			   (when (< depth 1)
			     (gv source-node :is-a-inv))))
   (:info-function #'(lambda (source-node)
		       (string-capitalize
			(kr:name-for-schema source))))
   (:source-roots (list opal:view-object))
   @i[; Change the node prototype so that it will go black]
   @i[; when the interactor sets] :interim-selected @i[to T]
   (:node-prototype
    (create-instance NIL opal:aggregraph-node-prototype
       (:interim-selected NIL)  @i[; Set by interactor]
       (:parts
	`((:box :modify
	   (:filling-style ,(o-formula (if (gvl :parent :interim-selected)
					   opal:black-fill
					   opal:white-fill)))
	   (:draw-function :xor) (:fast-redraw-p T))
	  :text-al))))
   @i[; Now define an interactor to work on all nodes of the graph]
   (:interactors
    `((:press ,inter:menu-interactor
       (:window ,(o-formula (gv-local :self :operates-on :window)))
       (:start-where ,(o-formula (list :element-of
                                       (gvl :operates-on :nodes))))
       (:final-function
	,#'(lambda (inter node)
	     (let* ((graph (gv node :parent :parent))
		    (source-node (gv node :source-node)))
	       (format T "~%~% ***** Clicked on ~S *****~%" source-node)
	       (kr:ps source-node))))))))
@end(programexample)
@end(group)

@begin(figure)
@Center[@graphic(Postscript="aggregadgets/schema-graph-2.ps",boundingbox=File,magnify=.75)]
@caption(Graph generated by SCHEMA-GRAPH-2)
@tag(schema-graph-2-pix)
@end(figure)

The graph of figure @ref(schema-graph-2-pix) comes from the definition of
SCHEMA-GRAPH-2.  This aggregraph models the same Garnet hierarchy as in the
previous example, but it also modifies the node-prototype for the
aggregraph and adds an interactor to operate on the graph.

The @pr(:node-prototype) slot must contain a Garnet object that can be used
to display the nodes of the graph.  In this case, the customized
node-prototype is an instance of the default node-prototype (which is an
aggregadget) with some changes in the roundtangle part.
The formula for the @pr(:filling-style) will make the node black
when the user presses on it with the mouse.

The interactor is defined as in aggregadgets and aggrelists.
Note that the @pr(:start-where) slot looks at the
components of the @pr(:nodes) aggregate in the top-level aggregraph.

Aggregadget nodes can be moved easily with an @pr(inter:move-grow-interactor).
By setting the @pr(:slots-to-set) slot of the interactor to
@pr[(list T T NIL NIL)], you can change the @pr(:left) and @pr(:top) of the
aggregraph nodes as you click and drag on them.


@Section(Aggregraph)
@label(aggregraph-slots)
@index(aggregraph slots)

Features and operation of an Aggregraph
        @begin(itemize)
                Creates a graph in which each node determines its own
                size based on information to be displayed in it.
                (The information is determined by the function
                @pr[:info-function].)

                The user must supply a list of source-nodes to be the
                root of the graph, a children-function which can
                be used to walk the user's graph, and an info-function to
                determine what will be displayed in each graph node.

                It is an instance of aggregadget, and interactors can be
                defined as in aggregadgets.
        @end(itemize)

@b(Customizable slots)
        @begin(description, leftmargin=10, indent=-6)
                @pr(:left), @pr(:top) -- The position of the aggregraph.
                Default is 0,0.

                @pr(:source-roots) -- List of source nodes to be used as the
                roots of the graph. 

                @pr(:children-function) -- A function which takes a source
                node and the depth from the root and
                returns a list of children.  The children are treated
                as unordered by the default layout-function.

                @pr(:info-function) -- A function which takes a source node and
                returns information to be used in the display of the
                node prototype.  The result is put in the @pr(:info) slot
                of the corresponding graph-node.  The default node-prototype
                expects a string to be returned.

                @pr(:add-back-pointer-to-nodes-function) -- A function or NIL.
                The function, if present, will be called on every
                source-node graph-node pair.  The result of the
                function is ignored.  This allows pointers to be
                put in the source-nodes for corresponding graph-nodes.

                @pr(:node-prototype) -- A Garnet object for node prototype, or
                list of prototypes (in which case a
                @pr(:node-prototype-selector-function) must be
                provided--see below).  In the
                instances, the @pr(:info) slot is set with the result of the
                info-function called on the corresponding source-node.  The
		@pr(:source-node) slot is set to the corresponding source node.
                And, the @pr(:links-to-me) and @pr(:links-from-me) slots are
                set to
                lists of graph links pointing to the node and from the node
                respectively.  The slots whose names begin with
"@pr(:layout-info)" are reserved for use by the layout functions for internal
bookkeeping and so should not be set by the user (unless writing a new
layout or associated methods). If any @pr(scalable-aggregraph-image) graphs are
made of this graph, the @pr(:image-nodes) slot is set to a list containing the
nodes that correspond to this node.  The default prototype expects a string in
the @pr(:info) slot, and displays the string with a white-filled
roundtangle surrounding it. 

                @pr(:link-prototype) -- Garnet object for link prototype, or
list of prototypes (in which case a @pr[:link-prototype-selector-function]
must be provided--see below).
                The @pr(:from) and @pr(:to) slots are set to the graph-nodes
                that this link connects.  The @pr(:image-links) slot is set to
a list of corresponding links to this one in associated
@pr(scalable-aggregraph-image) graphs.  The default prototype is a 
                line between these two graph nodes.  (It is connected
                to the center of the right side of the @pr(:from) node and
                to the center of the left side of the @pr(:to) node.  This
                assumes a left to right layout of the graph for
                pleasing display.  For other layout strategies, a
                different prototype may be desired.)  For directed
                graphs, a link prototype with an arrowhead may be desired.

@pr(:node-prototype-selector-function) -- A function which takes a source node and the list
of prototypes provided in the @pr(:node-prototype) slot and returns one of the
prototypes.  Will only be used if the value in the @pr(:node-prototype) slot is a
list. 

@pr(:link-prototype-selector-function) -- A function which takes a "from" graph-node, a "to"
graph-node and the list of prototypes provided in the @pr(:link-prototype) slot and
returns one of the prototypes.  Will only be used if the value in the
@pr(:link-prototype) slot is a list.

                @pr(:h-spacing) -- The minimum distance in pixels
                between nodes horizontally if using default layout-function.
                The default value is 20.

                @pr(:v-spacing) -- The minimum distance in pixels
                between nodes vertically if using default layout-function.  The
                default value is 5.

@pr(:test-to-distinguish-source-nodes) -- Must be one of @pr(#'eq), @pr(#'eql),
or @pr(#'equal).  The default is @pr(#'eql).

                @pr(:interactors) -- Specified in the same format as
		aggregadgets.

@pr(:layout-info-...) -- Several slots that begin with "@pr(:layout-info-)"
are reserved for bookkeeping by the layout function.  Do not set these slots
except as part of a customized layout function.

@end(description)


   
@b(Read-only slots)

@begin(description, leftmargin=10, indent=-6)

@pr(:nodes) -- The aggregate which contains all of the graph-node objects.

@pr(:links) -- The aggregate which contains all of the graph link objects.

@pr(:graph-roots) -- The list of graph nodes corresponding to the
@pr(:source-roots).

@pr(:image-graphs) -- The list of @pr(scalable-aggregraph-image) graphs that
                      are images of this graph.
@end(description)


@b[Methods] (can be overridden)

        @begin(description, leftmargin=10, indent=-6)
                @pr(:layout-graph) -- a function which is called to determine
                the locations for all of the nodes in the graph.  Takes
                the graph object as input and sets appropriate slots in
each node to position the node (usually @pr[:left] and @pr[:top] slots.)
Automatically called when graph is initially created.


                @pr(:delete-node) -- Takes the graph object and a graph node
and deletes it and all links attached to it.  If a node is deleted that
is a root of the graph, then it is removed from @pr(:graph-roots) and the
corresponding source-node is removed from @pr(:source-roots).

                @pr(:add-node) -- The arguments are the graph object, a
                source-node, a list of
                parent graph-nodes, and a list of children
                graph-nodes.  It creates a new graph node and places
                it in the graph positioning it appropriately.  Returns NIL.

                @pr(:delete-link) -- Takes the graph object and a graph link
and removes the link from the graph.

                @pr(:add-link) -- Takes the graph object and two graph nodes
and creates a link from the first node to the second.

                @pr(:source-to-graph-node) -- Takes the graph object and a
source node and returns the corresponding graph-node.

                @pr(:find-link) -- Takes the graph object and two graph-nodes
and returns the list of 
                graph link-objects from the first to the second.

@pr(:make-root) -- Takes the graph object and a graph node of the graph and
adds the graph node to the root lists of the graph.

@pr(:remove-root) -- Takes the graph object and a graph node and removes the
node from the root lists of the graph.

      @end(description)

Note that these eight methods depend on each other for
intelligent layout. If one is changed it will either
have to keep certain bookkeeping information, or other
functions will have to be changed as well.

The functions which add and delete nodes and links all
attempt to minimally change the graph.  The relayout
function may dramatically change it.


@Section(Scalable Aggregraph)
@index(scalable aggregraph)

Features and operation of a Scalable Aggregraph
        @begin(itemize)
                This object is similar to the normal aggregraph
                except that it can be scaled by the user.
                Text will be displayed only if it will fit within the
                scaled size of the graph nodes with the default prototypes.
		The scale factor is set by the @pr(:scale-factor) slot.

                The scalable aggregraph will automatically resize if the
                @pr(:scale-factor) slot is changed.

                It is an instance of aggregadget, and interactors can be
                defined as in aggregadgets.
        @end(itemize)

@b[Customizable slots] (same as for @pr(aggregraphs) except for the following):

        @begin(description, leftmargin=10, indent=-6)
                @pr(:scale-factor) -- A multiplier of full size which determines
                the final size of the graph (e.g. 1 causes the graph to be
                full size, 0.5 causes the graph to be half of full size, etc.)
The full size of the graph is determined by the size of the node prototypes and
layout of the nodes.

                @pr(:node-prototype) -- Must be able to set the @pr(:width) and
                @pr(:height), otherwise the same as in aggregraph.  These slots must
have initial values which will be used as their default value (i.e. the width
and height of the nodes is @pr(:scale-factor) * the values in @pr(:height) and @pr(:width)
slots respectively.

                @pr(:link-prototype) -- Position and size must depend on the nodes
it is attached to (by the @pr(:from) and @pr(:to) slots) with formulas.

@pr(:h-spacing) and @pr(:v-spacing) are the default
values.  The actual values are @pr(:scale-factor) * these values.
        @end(description)


@b(Read-only slots)

The same read-only slots are available as with @pr(aggregraph)
(see section @ref[aggregraph-slots]).


@b(Methods) (can be overridden)

The same methods are available as with @pr(aggregraph) (see section
@ref[aggregraph-slots]).



@Section(Scalable Aggregraph Image)
@index(scalable aggregraph image)

Features and operation of Scalable Aggregraph Image
        @begin(itemize)
                This is designed to show another view of an
                existing aggregraph.  This image is created with the
                same shape as the original, i.e. the size of nodes and
                relative positions are in proportion to the original.
                The proportion is determined by the @pr(:scale-factor) or
                @pr(:desired-height) and @pr(:desired-width) slots.  

                The size and shape are determined by Garnet formulas.
                This has the effect of maintaining the likeness to the
                original even as the original is manipulated and
                changed.

                The default prototypes (in particular the node
                prototype), are designed for the image to be used as
                an overview of a graph which perhaps doesn't fit on
                the screen.  This is why no text is displayed in
                nodes, for example.  This is not the only use of the
                gadget, especially if the prototypes are changed.
        @end(itemize)

@b(Customizable slots)

        @begin(description, leftmargin=10, indent=-6)
                @pr(:left), @pr(:top) -- The position of the aggregraph.
                Default is 0,0.

                @pr(:desired-width) and @pr(:desired-height) -- Desired width
                and height of the entire graph.  The graph will be
                scaled to fit inside these maximums.

                @pr(:source-aggregraph) -- The aggregraph to make an image of.

                @pr(:scale-factor) -- A multiplier of full size which
		determines
                the final size of the graph (e.g. 1 causes the graph to be
                the same size as the source aggregraph, 0.5 causes the graph to
		be half the size, etc.) 
                Scale-factor overrides the @pr(:desired-width) and
                @pr(:desired-height) slots if all are specified.
                The default value is 1.

                @pr(:node-prototype) -- Garnet object for node prototype, or a list
of prototypes (in which case a @pr(:node-prototype-selector-function) must be
provided--see below).  The @pr(:width), @pr(:height), @pr(:left) and @pr(:top)
slots must all be
settable, and the node size and position must depend on these slots.  They will
all be overridden with formulas in the created instances.
                The @pr(:corresponding-node) slot is set to the corresponding node
                in the source aggregraph.  The default
                node-prototype is a roundtangle proportional to the bounding
                box of the corresponding node in the source aggregraph
(because of the formulas).

                @pr(:link-prototype) -- Same as in aggregraph, except the
                @pr(:corresponding-link) slot is set to the corresponding link in
                the source aggregraph and there is no @pr(:from) or @pr(:to) slot.  The
@pr(:x1), @pr(:y1), @pr(:x2) and @pr(:y2) slots of the link must all be
settable, and the link
endpoints must depend on their values.  They will all be overridden with
formulas in the created instances.  The default link-prototype is a line.

@pr(:node-prototype-selector-function) -- A function which takes the appropriate
corresponding-node and the list of prototypes provided in the @pr(:node-prototype)
slot and returns one of the prototypes.  Will only be used if the value in the
@pr(:node-prototype) slot is a list.

@pr(:link-prototype-selector-function) -- A function which takes the
corresponding-link and the list of prototypes provided in
the @pr(:link-prototype) slot and returns one of the prototypes.
Will only be used if the value in the @pr(:link-prototype) slot is a list.

                @pr(:interactors) -- Specified in the same format as
		aggregadgets.
        @end(description)


@b(Read-only slots)

The same read-only slots are available as with @pr(aggregraph) except
@pr(:graph-roots) (see section @ref[aggregraph-slots]).


@b(Methods) (probably shouldn't be overridden)

The methods of a @pr(scalable-aggregraph-image) call the methods of the source
aggregraph, and changes are reflected in the image.  If the methods of the
source graph are called directly, the changes will also be reflected.

When this aggregraph image is created, pointers are created in the source
aggregraph and all of its nodes and links to the corresponding image graph,
nodes and links.  These pointers are added to a list in the slot
@pr(:image-graphs), @pr(:image-nodes) and @pr(:image-links)
of the aggregraph, nodes and links.  Pointers from the image
to the source are in the slots @pr(:source-aggregraph),
@pr(:source-node) and @pr(:source-link) as indicated below.
These links are used by the methods (both in this
gadget and in the two gadgets described above) to maintain the image.



@Section(Customizing the :layout-graph Function)
@label(layout-graph)
@index(layout-graph)
@index(layout function)

@b(NOTE:)  Writing a customized layout function is a formidable task that
few users will want to try.  This section is provided for programmers whose
aggregraph application requires a graph layout that is not suited to the
default tree layout function.

The function stored in @pr(:layout-graph) computes the locations for all of
the nodes and links of the graph.
It takes the graph as its argument, and the returned value is ignored.
All nodes have been created with their height and width, and are
connected to the appropriate links and nodes, before the function is called.

The default layout function is @pr(layout-tree) defined in @pr(Opal).
This function can be called repeatedly
on the graph, but may drastically change the look of the graph (if a series
of adds and deletes were done before the relayout).  Features of
@pr(layout-tree) are:

@begin(itemize)
It works best for trees and DAGs which are tree-like
(i.e. DAGs in which the width becomes larger toward the leaves).

It takes linear time in the number of nodes.

Children are treated as unordered.

Add and delete (both nodes and links) attempt to minimally change the
graph.
@end(itemize)

If a new layout function is written without regard to the bookkeeping
slots or the various methods associated with the aggregraph, the other methods
will work with the new layout function but will probably not keep the graph
looking as nice as possible.

With the default link prototypes it is only necessary to place the nodes,
because the links attach to the nodes automatically with Garnet formulas.
(Note that the default links are designed for a left to right layout of the
graph.  If a different layout is desired another prototype may be desired.  Of
course, formulas can still be used rather than explicitly placing each link.)

In general, the other graph methods may need to maintain or use the same
bookkeeping information as the layout function.  For example, @pr(add-node) and
@pr(delete-node)
both affect the "@pr(:layout-info-)" slots used by the default layout function.
(Specifically they add or delete rectangles respectively from the object
stored in the @pr(:layout-info-rect-conflict-object) slot of the graph object.
This object keeps track of all rectangles (nodes) placed on the graph and when
queried with a new rectangle returns any stored rectangles that it overlaps.)
When redefining the layout function, it may be necessary to redefine these
functions.



@Comment(page break untilodd so index will be on an odd page)
@begin(text,pagebreak=untilodd)
@end(text)
