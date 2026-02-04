(include "html-lib.scm")

(define SRFI "231-bis") ;; must be a string

(define (<cv> . args)
  (<code>(apply <var> args)))

(define (format-lambda-list lst #!optional id)
  (let ((name (car lst))
        (arguments (cdr lst)))
    (<p> (<b> "Procedure: ")
         (<code> (<a> id: (if id id name) name)
                 (map (lambda (arg)
                        (list " " (cond ((symbol? arg)
                                         (<var> arg))
                                        ((keyword? arg)
                                         arg)
                                        (else
                                         arg))))
                      arguments)))))

(define (format-global-variable name)
  (<p> (<b> "Variable: ")
       (<code> (<a> id: name name))))

(define (format-parameter name)
  (<p> (<b> "Parameter: ")
       (<code> (<a> id: name name))))

(with-output-to-file
    "srfi-231.html"
  (lambda()
    (html-display
     (list
      (<unprotected> "<!DOCTYPE html>")
      (<html>
       lang: 'en
       (<head>
        (<meta> charset: "utf-8")
        (<title> (string-append "SRFI " SRFI ": Intervals and Generalized Arrays"))
        (<link>
         rel: "icon"
         sizes: "192x192"
         type: "image/png"
         href: "/favicon.png"
         )
        (<link> href: "https://srfi.schemers.org/srfi.css"
                rel: "stylesheet"
                type: "text/css")
        (<meta> name: 'viewport
                content: "width=device-width, initial-scale=1")
        (<script> type: "text/x-mathjax-config" "
MathJax.Hub.Config({
  tex2jax: {inlineMath: [['$','$'], ['\\\\(','\\\\)']]}
});")
        (<script> crossorigin: "anonymous"
                  integrity:"sha384-Ra6zh6uYMmH5ydwCqqMoykyf1T/+ZcnOQfFPhDrp2kI4OIxadnhsvvA2vv9A7xYv"
                  src: "https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=TeX-AMS-MML_HTMLorMML")
        )
       (<body>
        (<h1> (<a> href: "https://srfi.schemers.org/" (<img> class: 'srfi-logo src: "https://srfi.schemers.org/srfi-logo.svg" alt: "SRFI logo")) SRFI ": Intervals and Generalized Arrays")

        (<p> " by Bradley J. Lucier")

        (<h2> id: 'status "Status")
        (<p> "This document follows up SRFI 231 with a few changes whose necessity arose after SRFI 231 was finalized. To provide input on this document, please send email to "
             (<code> (<a> href: (string-append "mailto:srfi+minus+231+at+srfi+dotschemers+dot+org")
                          (string-append "srfi-231@") (<span> class: "antispam" "nospam") "srfi.schemers.org"))
                     ".  To subscribe to the list, follow "
             (<a> href: "https://srfi.schemers.org/srfi-list-subscribe.html" "these instructions")
             ".  You can access previous messages via the mailing list "
             (<a> href: "https://srfi-email.schemers.org/srfi-231/" "archive")".")

        (<h2> "Abstract")
        (<p>
         "This SRFI specifies an array mechanism for Scheme. Arrays as defined here are quite general; at their most basic, an array is simply a "
         "mapping, or function, from multi-indices of exact integers $i_0,\\ldots,i_{d-1}$ to Scheme values.  The set of multi-indices "
         "$i_0,\\ldots,i_{d-1}$ that are valid for a given array form the "(<i>'domain)" of the array.  In this SRFI, each array's domain consists "
         " of the cross product of intervals of exact integers $[l_0,u_0)\\times[l_1,u_1)\\times\\cdots\\times[l_{d-1},u_{d-1})$ of $\\mathbb Z^d$, $d$-tuples of "
         "integers.  Thus, we introduce a data type "
         "called $d$-"(<i> 'intervals)", or more briefly "(<a> href: "https://en.wikipedia.org/w/index.php?title=Interval_(mathematics)&oldid=1091935326" (<i>'intervals))", that encapsulates this notion. (We borrow this terminology from, e.g., "
         " Elias Zakon's "(<a> href: "http://www.trillia.com/zakon1.html" "Basic Concepts of Mathematics")".) "
         "Specialized variants of arrays provide portable programs with efficient representations for common use cases.")
        (<p> "This is a revised and improved version of "(<a> href: "https://srfi.schemers.org/srfi-231/" "SRFI 231")".")
        (<h2> "Contents")
        (<ul>
         (<li> (<a> href: "#Rationale" "Rationale"))
         (<li> (<a> href: "#Overview" "Overview")
               (<ul>
                (<li> (<a> href: "#Introductory" "Introductory remarks"))
                (<li> (<a> href: "#Bawden" "Bawden-style arrays"))
                (<li> (<a> href: "#extension" "Our extensions of Bawden-style arrays"))
                (<li> (<a> href: "#transformations" "Common transformations on Bawden-style arrays"))
                (<li> (<a> href: "#generalized" "Generalized arrays"))
                (<li> (<a> href: "#sharing" "Sharing generalized arrays"))
                (<li> (<a> href: "#array-broadcasting" "Array broadcasting")
                      (<ul>
                       (<li> (<a> href: "#explicit-array-broadcasting" "Explicit array broadcasting"))
                       (<li> (<a> href: "#implicit-array-broadcasting" "Implicit array broadcasting"))))
                (<li> (<a> href: "#convention" "Notational convention"))))
         (<li> (<a> href: "#Notes" "Notes"))
         (<li> (<a> href: "#Specification" "Specification"))
         (<li> (<a> href: "#Preliminary" "Preliminary notes"))
         (<li> (<a> href: "#Miscellaneous" "Miscellaneous procedures")
               (<ul>
                (<li> (<a> href: "#miscprocedures" "Procedures"))))
         (<li> (<a> href: "#Intervals" "Intervals")
               (<ul>
                (<li> (<a> href: "#intervalprocedures" "Procedures"))))
         (<li> (<a> href: "#Storage" "Storage classes")
               (<ul>
                (<li> (<a> href: "#storageprocedures" "Procedures"))
                (<li> (<a> href: "#storageglobals" "Global variables"))))
         (<li> (<a> href: "#Arrays" "Arrays")
               (<ul>
                (<li> (<a> href: "#parameters" "Parameters"))
                (<li>(<a>  href: "#arrayprocedures" "Procedures"))))
         (<li> (<a> href: "#Implementation" "Implementation"))
         (<li> (<a> href: "#relationship" "Relationship to other array libraries")
               (<ul>
                (<li> (<a> href: "#NumPy" "NumPy arrays"))
                (<li> (<a> href:"#othersrfis" "Other SRFIs"))
                (<li>  (<a> href: "#Racket" "Racket's array library"))))
         (<li> (<a> href: "#otherexamples" "Other examples"))
         (<li> (<a> href: "#Acknowledgments" "Acknowledgments"))
         (<li> (<a> href: "#References" "References"))
         (<li> (<a> href: "#Copyright" "Copyright")))
        (<h2> (<a> id: "Rationale" "Rationale"))
        (<p> "This SRFI was motivated by a number of somewhat independent notions, which we outline here and which are explained below.")
        (<ul>
         (<li> "Provide a "(<b> "general API")" (Application Program Interface) that specifies the minimal required properties of any given array, without requiring any specific implementation strategy from the programmer for that array.")
         (<li> "Provide a "(<b> "single, efficient implementation for dense arrays")" (which we call "(<i>"specialized arrays")").")
         (<li> "Provide "(<b> "useful array transformations")".")
         (<li> "Separate "(<b>"the procedures that specify the work to be done")" ("(<code>'array-map)", "(<code>'array-outer-product)", etc.) from "(<b>"the procedures that actually do the work")" ("(<code>'array-copy)", "(<code>'array-assign!)", "(<code>'array-fold-left)", etc.). This approach "(<b> "avoids temporary intermediate arrays")" in computations.")
         (<li> "Encourage " (<b> "bulk processing of arrays")" rather than word-by-word operations.")
         )
        (<p> "This SRFI differs from the finalized " (<a> href: "https://srfi.schemers.org/srfi-231/" "SRFI 231")" in the following ways:")
        (<ul>
         (<li> "The implementation no longer specifies, or implements, a difference between \"safe\" and \"unsafe\" arrays.  The getters and setters of all arrays made in the library check array indices for correctness; the setters of mutable specialized arrays check that the values they store into arrays are of the correct type.  (Internally, the sample implementation maintains \"unsafe\" setters and getters that are used in \"bulk\" array operations where the arguments are known to be appropriate.) So procedure arguments that specify whether array results are \"safe\" have been removed, as has the parameter "(<code> "specialized-array-default-safe?")".")
         (<li> "The calling sequences for "(<a> href: "#interval-fold-left"(<code>'interval-fold-left))" and "(<a> href: "#interval-fold-right"(<code>'interval-fold-right))" have been changed.")
         (<li> (<code>'array-freeze!)" has been removed as a user-visible procedure.  Because array setters are reified and can be stored in structures, passed as arguments, etc., one cannot truly \"freeze\" a mutable array to make an immutable array.")
         (<li> "The default entry for arrays of generic-storage-class is now 0, not "(<code>'#f)", which we find to be more useful.")
         (<li> "The routines "(<code>'array-outer-product)" and "(<code>'array-inner-product)" are now specified to copy generalized array arguments to specialized arrays, evaluating all elements of such an array in an unspecified order.  The procedure "(<code>'array-inner-product)" now returns a specialized, not a generalized, array result.")
         (<li> "Both "(<a> href: "#explicit-array-broadcasting" "explicit")" and "(<a> href: "#implicit-array-broadcasting" "implicit")" array broadcasting are specified in this SRFI extension and in implemented in the sample implementation.")
         (<li> "The parameter "(<a> href: "#array-broadcasting?" "array-broadcasting?")" has been added to the SRFI.")
         (<li> "The routines "
               (<a> href: "#interval-rebase" (<code>'interval-rebase))", "
               (<a> href: "#array-rebase" (<code>'array-rebase))", "
               (<a> href: "#interval-insert-axis" (<code>'interval-insert-axis))", "
               (<a> href: "#object-rarrow-array" (<code>'object->array))", "
               (<a> href: "#array-insert-axis" (<code>'array-insert-axis))", "
               (<a> href: "#compute-broadcast-interval" (<code>'compute-broadcast-interval))","
               (<a> href: "#array-broadcast" (<code>'array-broadcast))
               " have been added to the SRFI.")
         )

        (<h2> (<a> id: "Overview" "Overview"))

        (<h3> (<a> id: "Introductory" "Introductory remarks"))

        (<p> "The next few sections talk perhaps too much about the mathematical ideas that underpin many of the procedures in this SRFI, so I discuss here some of the more commonly used procedures and compare them to operations on spreadsheets,  matrices, and imaging.")
        (<p> "There are two procedures that simply create new arrays:")
        (<ul>
         (<li> (<a> href: "#make-array" (<code>'make-array))": Takes as arguments a specification of the valid indices $i\\ j\\ k$ etc. of the array, together with a Scheme procedure, which, when presented with indices in the valid range, computes the array element.   The elements of the array are not precomputed and stored somewhere; the specified procedure is recomputed each time that element is needed.  A procedure that modifies which element is returned at a given set of indices is allowed as a third argument.  See the sparse matrix example below to see how this is useful.  We call the result a "(<i>"generalized array")".")
         (<li> (<a> href: "#make-specialized-array"(<code>'make-specialized-array))": Takes as an argument a specification of a valid range of indices and reserves a block of memory in which to store elements of the matrix. Elements are stored in row-major order, as in C.  We call the result a "(<i>"specialized array")".")
         )
        (<p> "In the next group of procedures, the new and old arrays share elements, so modifications to one affect the others.  Also, none of these procedures move any data: for specialized arrays they just change how the data are indexed, while for generalized arrays they manipulate the arguments of the getter and setter.  For specialized arrays, these procedures can be combined in any way without increasing unreasonably the number of operations required to access an array element.")
        (<ul>
         (<li> (<a> href: "#array-extract" (<code>'array-extract))
               ": Constructs a rectangular \"window\" or \"view\" into an existing array, like a rectangular region of a spreadsheet, or a submatrix of a matrix.")
         (<li> (<a> href: "#array-translate" (<code>'array-translate))
               ": Slides an array around, like changing the zero-based indexing of C arrays to the 1-based indexing of Fortran arrays. If you wanted to compare two subimages of the same number of rows and columns of pixels, for example, you could use " (<code>'array-extract)" to select each of the subimages, and then use "(<code>'array-translate)" to overlay one on the other, i.e., to use the same indexing for both. " (<a> href: "#array-rebase" (<code>'array-rebase))" is like "(<code>'array-translate)" except that you specify the lower bounds of the new array instead of specifying the translation.")
         (<li> (<a> href: "#array-permute"(<code>'array-permute))
               ": Swaps rows, columns, sheets, etc., of the original array, like swapping rows and columns in a spreadsheet or transposing a matrix.  The auxiliary procedures "(<code>'index-rotate)", "(<code>'index-first)",  "(<code>'index-last)", and "(<code>'index-swap)" create commonly used permutations.")
         (<li> (<a> href:"#array-reverse" (<code>'array-reverse))
               ": Reverses the order of rows or columns (or both) of a spreadsheet.  Like flipping an image vertically or horizontally.")
         (<li> (<a> href:"#array-sample" (<code>'array-sample))
               ": Accesses every second (or third, etc.) row or column, or both, of an array.")
         (<li> (<a> href: "#array-insert-axis" (<code>'array-insert-axis))
               ": Inserts an axis into its array argument with lower bound 0 and upper bound 1.  Useful for setting up array broadcasting.")
         )
        (<p> "The following two procedures decompose arrays in different ways.  They return "(<i>"generalized arrays")" whose elements are themselves arrays. Like the procedures described immediately above, the resulting subarrays share elements with their argument.")
        (<ul>
         (<li> (<a> href: "#array-curry"(<code>"array-curry"))
               ": Represents a $d$-dimensional array as a $d'$-dimensional array whose entries are themselves arrays of dimension $d-d'$.  Like thinking of a three-dimensional CT scan as a one-dimensional array of two-dimensional slices, or thinking of a matrix as a one-dimensional array of one-dimensional rows.  You could combine this operation with "(<code>'array-permute)" to think of a matrix as an array of columns, or look at slices in different orientations of a three-dimensional CT scan.  Considering a video as a one-dimensional sequence (in time) of two-dimensional stills (in space) is another example of currying. The subarrays share elements with the original array.  The procedures "(<code>'array-decurry)" and "(<code>'array-stack)", described below, reverse this process.")
         (<li> (<a> href: "#array-tile" (<code>'array-tile))
               ": Decomposes a $d$-dimensional array into $d$-dimensional sub-blocks with cuts parallel to the coordinate axes, and returns the subarrays in an array.  Like breaking a large matrix into smaller matrices for block matrix operations. The subarrays share elements with the original array.  The procedures "(<code>'array-block)" and "(<code>'array-append)", described below, reverse this process.")
         )

        (<p> "The next few procedures set up operations to be executed in the future.  They build "(<i> "generalized")" arrays.")
        (<ul>
         (<li> (<a> href:"#array-map"(<code>'array-map))
               ": Specifies an operation to be applied componentwise on arrays, so if "(<code>(<var>'A))" and "(<code>(<var>'B))" are matrices, "(<code>"(array-map + "(<var>'A)" "(<var>'B)")")" sets up a new generalized array that adds elements of the arrays componentwise.  You can chain these operations, so have "(<code>"(array-map + (array-map (lambda ("(<var>'x)") (* "(<var>"alpha x")")) "(<var>'A)") "(<var>'B)")")" without immediately computing and storing all the values of those arrays.")
         (<li> (<a> href:"#array-outer-product"(<code>'array-outer-product))
               ": Applies an operation to all possible pairs of elements of two array arguments. Like considering an $m$-vector as a column vector and an $n$-vector as a row vector, and multiplying them together to compute an $m\\times n$ matrix.")

         )
        (<p> "Then, there are procedures that "(<i>'do)" generate all elements of an array and either store them somewhere, or combine them in some way:")
        (<ul>
         (<li> (<a> href:"#array-copy"(<code>'array-copy))
               ": Evaluates the argument array at all valid indices and stores those values into a new specialized array.")
         (<li> (<a> href:"#array-assign!"(<code>'array-assign!))
               ": Evaluates the argument array at all valid indices and assigns their values to the elements of an existing array.  In the Gaussian Elimination example below, we combine "(<code>'array-map)", "(<code>'array-outer-product)", "(<code>'array-extract)", and "(<code>'array-assign!)" to do one step of the elimination.")
         (<li> (<a> href:"#array-stack"(<code>'array-stack))
               ": Like taking the individually rendered frames of an animated movie and combining them in time to make a complete video.  Can be considered a partial inverse to "(<code>'array-curry)".  Returns a specialized array.")
         (<li> (<a> href:"#array-decurry" (<code>'array-decurry))
               ": Takes a \"curried\" array of arrays, and returns a single array with the same elements.  An inverse to "(<code>'array-curry)"; a multi-dimensional version of "(<code>'array-stack)".")
         (<li> (<a> href:"#array-append"(<code>'array-append))
               ": Like concatenating a number of images left to right, or top to bottom. Returns a specialized array.  A partial inverse to "(<code>'array-tile)".")
         (<li> (<a> href: "#array-block"(<code>'array-block))
               ": Assumes that an array has been decomposed into blocks by cuts perpendicular to each coordinate axis; takes an array of those blocks as an argument, and returns a reconstructed array.  An inverse to "(<a> href: "#array-tile" (<code>'array-tile))"; a multi-dimensional version of array-append.")
         (<li> (<a> href:"#array-inner-product"(<code>'array-inner-product))
               ": Like APL's inner product; multiplying two matrices is an example of an operation implemented using "(<code>'array-inner-product)".")
         (<li> (<a> href:"#array-fold-left"(<code>'array-fold-left))", "
               (<a> href:"#array-fold-right"(<code>'array-fold-right))", "
               (<a> href:"#array-reduce"(<code>'array-reduce))", "
               (<a> href:"#array-for-each"(<code>'array-for-each))", "
               (<a> href:"#array-any"(<code>'array-any))", and "
               (<a> href: "#array-every"(<code>'array-every))
               ": Evaluates all elements of an array (for "(<code>'array-every)" and "(<code>'array-any)", as many as needed to know the result), and combines them in certain ways.")
         )
        (<p> "Finally, we have procedures that convert between other data and arrays:")
        (<ul>
         (<li> (<a> href: "#make-specialized-array-from-data" (<code>'make-specialized-array-from-data))": Construct a specialized array whose body shares elements with an existing data structure.")
         (<li> (<a> href: "#array-rarrow-list" (<code>'array->list))", "
               (<a> href: "#list-rarrow-array" (<code>'list->array))", "
               (<a> href: "#array-rarrow-vector" (<code>'array->vector))", and "
               (<a> href: "#vector-rarrow-array" (<code>'vector->array))": Either transfer the elements of an array to a list or vector, or construct a specialized array from the elements of a list or vector.")
         (<li> (<a> href: "#array-rarrow-list*" (<code>'array->list*))", "
               (<a> href: "#list*-rarrow-array" (<code>'list*->array))", "
               (<a> href: "#object-rarrow-array" (<code>'object->array))", "
               (<a> href: "#array-rarrow-vector*" (<code>'array->vector*))", and "
               (<a> href: "#vector*-rarrow-array" (<code>'vector*->array))": Either transfer the elements of an array to a nested list or vector, or construct a specialized array from the elements of a nested list or vector."))
        (<p>"I hope this brief discussion gives a flavor for the design of this SRFI.")

        (<h3> (<a> id: "Bawden" "Bawden-style arrays"))
        (<p>  "In a "(<a> href: "https://groups.google.com/g/comp.lang.scheme/c/7nkx58Kv6RI/m/a5hdsduFL2wJ" "1993 post")
              " to the news group comp.lang.scheme, Alan Bawden gave a simple implementation of multi-dimensional arrays in R4RS scheme. "
              "The only constructor of new arrays required specifying an initial value, and he provided the three low-level primitives "
              (<code>'array-ref)", "(<code>'array-set!)", and "(<code>'array?)", as well as "(<code>'make-array)" and "(<code>'make-shared-array)
              ".  His arrays were defined on rectangular intervals in "
              "$\\mathbb Z^d$ of the form $[l_0,u_0)\\times\\cdots\\times [l_{d-1},u_{d-1})$.  I'll note that his procedure "(<code>'array-set!)
              " puts the value to be entered into the array at the front of the variable-length list of indices that indicate where to "
              "place the new value.  He offered an intriguing way to \"share\" arrays "
              "in the form of a procedure "(<code>'make-shared-array)" that took a mapping from a new interval of indices into the domain "
              "of the array to be shared.  His implementation incorporated what he called an "(<i>'indexer)", which was a procedure from "
              "the interval $[l_0,u_0)\\times\\cdots\\times [l_{d-1},u_{d-1})$ to an interval $[0,N)$, where the "(<i>'body)" of the array consisted of "
              "a single Scheme vector of length $N$.  Bawden called the mapping specified in "(<code>'make-shared-array)" "
              (<i>'linear)", but I prefer the term "(<i>'affine)", as I explain later.")
        (<p> "Mathematically, Bawden's arrays can be described as follows.  We'll use the vector notation $\\vec i$ for a multi-index "
             "$i_0,\\ldots,i_{d-1}$. (Multi-indices correspond to Scheme "(<code>'values)".)  Arrays will be denoted by capital letters "
             "$A,B,\\ldots$, the domain of the array $A$ will be denoted by $D_A$, "
             "and the indexer of $A$, mapping $D_A$ to the interval $[0,N)$, will be denoted by $I_A$.  Initially, Bawden constructs "
             "$I_A$ such that $I_A(\\vec i)$ steps consecutively through the values $0,1,\\ldots,N-1$ as $\\vec i$ steps through the "
             "multi-indices $(l_0,\\ldots,l_{d-2},l_{d-1})$, $(l_0,\\ldots,l_{d-2},l_{d-1}+1)$, $\\ldots$, $(l_0,\\ldots,l_{d-2}+1,l_{d-1})$, etc., in lexicographical order, which means "
             "that if $\\vec i$ and $\\vec j$ are two multi-indices, then $\\vec i<\\vec j$ if and only if the least coordinate $k$ where $\\vec i$ and $\\vec j$ "
             "differ satisfies $\\vec i_k<\\vec j_k$.  This ordering of multi-indices is also known as "(<a> href: "https://en.wikipedia.org/w/index.php?title=Row-_and_column-major_order&oldid=995330290" "row-major order")
             ", which is used in the programming language C to order the elements of multi-dimensional arrays.  In contrast, the programming language Fortran uses column-major order to order the elements of multi-dimensional arrays.")
        (<p> "In "(<code>'make-shared-array)", Bawden allows you to specify a new $r$-dimensional interval $D_B$ as the domain of a new array $B$, and a "
             "mapping $T_{BA}:D_B\\to D_A$ of the form $T_{BA}(\\vec i)=M\\vec i+\\vec b$; here $M$ is a $d\\times r$ matrix of integer values and "
             "$\\vec b$ is a $d$-vector.  So this mapping $T_{BA}$ is "(<i>'affine)", in that $T_{BA}(\\vec i)-T_{BA}(\\vec j)=M(\\vec i-\\vec j)$ is "
             (<i>'linear)" (in a linear algebra sense) in $\\vec i-\\vec j$.  The new indexer of $B$ satisfies $I_B(\\vec i)=I_A(T_{BA}(\\vec i))$.")
        (<p> "A fact Bawden exploits in the code, but doesn't point out in the short post, is that $I_B$ is again an affine map, and indeed, the composition "
             "of "(<i>'any)" two affine maps is again affine.")
        (<h3> (<a> id: "extension" "Our extensions of Bawden-style arrays"))
        (<p> "We incorporate Bawden-style arrays into this SRFI, but extend them in one minor way that we find useful.")
        (<p> "We introduce the notion of a "(<i>"storage class")", an object that contains procedures that manipulate, store, check, etc., different types of values. "
             "The "(<code>'generic-storage-class)" can manipulate any Scheme value, "
             "whereas, e.g., a "(<code>'u1-storage-class)" can store only the values 0 and 1 in each element of a body.")
        (<p> "We generally require that our affine maps be one-to-one, so that if $\\vec i\\neq\\vec j$ then $T(\\vec i)\\neq T(\\vec j)$.  Without this property, modifying "
             "the $\\vec i$th component of $A$ would cause the $\\vec j$th component to change.")
        (<h3> (<a> id: "transformations" "Common transformations on Bawden-style arrays"))
        (<p> "Requiring the transformations $T_{BA}:D_B\\to D_A$ to be affine may seem  esoteric and restricting, but in fact many common and useful array transformations "
             "can be expressed in this way.  We give several examples below: ")
        (<ul>
         (<li> (<b> "Restricting the domain of an array: ")
               "  If the domain of $B$, $D_B$, is a subset of the domain of $A$, then $T_{BA}(\\vec i)=\\vec i$ is a one-to-one affine mapping.  We define "
               (<code>'array-extract)" to define this common operation; it's like looking at a rectangular sub-part of a spreadsheet. We use it to extract the common part of overlapping domains of three arrays in an image processing example below. ")
         (<li> (<b> "Tiling an array: ")
               "For various reasons (parallel processing, optimizing cache localization, GPU programming, etc.), one may wish to process a large array as a number of subarrays of the same dimension.  We call this "(<i>'tiling)" the array.  The procedure "(<code>'array-tile)" returns a new array, each entry of which is a subarray extracted (in the sense of "(<code>'array-extract)") from the input array.")
         (<li> (<b> "Translating the domain of an array: ")
               "If $\\vec d$ is a vector of integers, then $T_{BA}(\\vec i)=\\vec i-\\vec d$ is a one-to-one affine map of $D_B=\\{\\vec i+\\vec d\\mid \\vec i\\in D_A\\}$ onto $D_A$. "
               "We call $D_B$ the "(<i>'translate)" of $D_A$, and we define "(<code>'array-translate)" to provide this operation.")
         (<li> (<b> "Permuting the coordinates of an array: ")
               "If $\\pi$ "(<a> href: "https://en.wikipedia.org/wiki/Permutation" 'permutes)" the coordinates of a multi-index $\\vec i$, and $\\pi^{-1}$ is the inverse of $\\pi$, then "
               "$T_{BA}(\\vec i)=\\pi (\\vec i)$ is a one-to-one affine map from $D_B=\\{\\pi^{-1}(\\vec i)\\mid \\vec i\\in D_A\\}$ onto $D_A$.  We provide "(<code>'array-permute)" for this operation. "
               "Several procedures build commonly used permutations: "(<code>"(index-rotate "(<var>'n)" "(<var>'k)")")" rotates "(<code>(<var>'n))" indices "(<code>(<var>'k))" places to the left; "(<code>"(index-first "(<var>'n)" "(<var>'k)")")" moves the $k$th of $n$ indices to be the first index, leaving the others in order;  "(<code>"(index-last "(<var>'n)" "(<var>'k)")")" moves the $k$th of $n$ indices to be the last index, again leaving the others in order; "(<code>"(index-swap "(<var>"n i j")")")" swaps the $i$th and $j$th of $n$ indices, again leaving the others in order.")
         (<li> (<b> "Currying an array: ")
               "Let's denote the cross product of two intervals $\\text{Int}_1$ and $\\text{Int}_2$ by $\\text{Int}_1\\times\\text{Int}_2$; "
               "if $\\vec j=(j_0,\\ldots,j_{r-1})\\in \\text{Int}_1$ and $\\vec i=(i_0,\\ldots,i_{s-1})\\in \\text{Int}_2$, then "
               "$\\vec j\\times\\vec i$, which we define to be $(j_0,\\ldots,j_{r-1},i_0,\\ldots,i_{s-1})$, is in $\\text{Int}_1\\times\\text{Int}_2$. "
               "If $D_A=\\text{Int}_1\\times\\text{Int}_2$ and $\\vec j\\in\\text{Int}_1$ is fixed, then $T_{BA}(\\vec i)=\\vec j\\times\\vec i$ "
               "is a one-to-one affine mapping from $D_B=\\text{Int}_2$ into $D_A$.  For each vector $\\vec j$ we can compute a new array in this way; we provide "
               (<code>'array-curry)" for this operation, which returns an array whose domain is $\\text{Int}_1$ and whose elements are themselves arrays, each of which is defined on $\\text{Int}_2$. "
               "Currying a two-dimensional array would be like organizing a spreadsheet into a one-dimensional array of rows of the spreadsheet.")
         (<li> (<b> "Traversing some indices in a multi-index in reverse order: ")
               "Consider an array $A$ with domain $D_A=[l_0,u_0)\\times\\cdots\\times[l_{d-1},u_{d-1})$. Fix $D_B=D_A$ and assume we're given a vector of booleans $F$ ($F$ for \"flip?\"). "
               "Then define $T_{BA}:D_B\\to D_A$ by $i_j\\to i_j$ if $F_j$ is "(<code>'#f)" and $i_j\\to u_j+l_j-1-i_j$ if  $F_j$ is "(<code>'#t)". "
               "In other words,  we reverse the ordering of the $j$th coordinate of $\\vec i$ if and only if $F_j$ is true. "
               "$T_{BA}$ is an affine mapping from $D_B\\to D_A$, which defines a new array $B$, and we can provide "(<code>'array-reverse)" for this operation. "
               "Applying "(<code>'array-reverse)" to a two-dimensional spreadsheet might reverse the order of the rows or columns (or both).")
         (<li> (<b> "Uniformly sampling an array: ")
               "Assume that $A$ is an array with domain $[0,u_1)\\times\\cdots\\times[0,u_{d-1})$ (i.e., an interval all of whose lower bounds are zero). "
               "We'll also assume the existence of vector $S$ of scale factors, which are positive exact integers. "
               "Let $D_B$ be a new interval with $j$th lower bound equal to zero and $j$th upper bound equal to $\\operatorname{ceiling}(u_j/S_j)$ and let "
               "$T_{BA}(\\vec i)_j=i_j\\times S_j$, i.e., the $j$th coordinate is scaled by $S_j$.  ($D_B$ contains precisely those multi-indices that $T_{BA}$ maps into $D_A$.) "
               "Then $T_{BA}$ is an affine one-to-one mapping, and we provide "(<code>'interval-scale)" and "(<code>'array-sample)" for these operations.")
         )
        (<p> "We make several remarks.  First, all these operations could have been computed by specifying the particular mapping $T_{BA}$ explicitly, so that these procedures are in some sense "
             "\"convenience\" procedures.  Second, because the composition of any number of affine mappings is again affine, accessing or changing the elements of a "
             "restricted, translated, curried, permuted array is no slower than accessing or changing the elements of the original array itself. "
             "Finally, we note that by combining array currying and permuting, say, one can come up with simple expressions of powerful algorithms, such as extending "
             "one-dimensional transforms to multi-dimensional separable transforms, or quickly generating two-dimensional slices of three-dimensional image data. "
             "Examples are given below.")

        (<h3> (<a> id: "generalized" "Generalized arrays"))
        (<p> "Bawden-style arrays are clearly useful as a programming construct, but they do not fulfill all our needs in this area. "
             "An array, as commonly understood, provides a mapping from multi-indices  $(i_0,\\ldots,i_{d-1})$ of exact integers
in a nonempty, rectangular, $d$-dimensional interval $[l_0,u_0)\\times[l_1,u_1)\\times\\cdots\\times[l_{d-1},u_{d-1})$, $l_k<u_k$ — the "(<i>'domain)" of the array — to Scheme objects.
Thus, two things are necessary to specify an array: an interval and a mapping that has that interval as its domain.")
        (<p> "Since these two things are often sufficient for certain algorithms, we introduce in this SRFI a minimal set of interfaces for dealing with such arrays.")
        (<p> "We also consider the case when $d>0$ and some $l_k=u_k$; in this case the mathematical cross product is empty, and arrays with such a domain have no elements but still \"dimension\" $d$.  Applying the mapping associated with this array is an error.")
        (<p> "Finally, we allow $d=0$; such an array would have one element, and its mapping is a function with no index arguments (i.e., a \"thunk\").")
        (<p> "So an array specifies a  multi-dimensional interval, called its "(<i> "domain")", and a mapping from this domain to Scheme objects.  This mapping is called the "(<i> 'getter)" of the array, accessed with the procedure "(<code>'array-getter)"; the domain of the array (more precisely, the domain of the array's getter) is accessed with the procedure "(<code>'array-domain)".")
        (<p> "If this mapping can be changed, the array is said to be "(<i> 'mutable)", and the mutation is effected
by the array's "(<i> 'setter)", accessed by the procedure "(<code>'array-setter)".  We call an object of this type a mutable array. Note: If an array does not have a setter, then we call it immutable even though the array's getter might not be a \"pure\" procedure, i.e., the value it returns may not depend solely on the arguments passed to the getter.")
        (<p> "In general, we leave the implementation of generalized arrays completely open.  They may be defined simply by closures, or
they may have hash tables or databases behind an implementation, or may read the values from a file, etc.")
        (<p> "In this SRFI, Bawden-style arrays are called "(<i> 'specialized)". A specialized array may be either mutable or immutable.")

        (<h3> (<a> id: "sharing" "Sharing generalized arrays"))
        (<p> "Even if an array $A$ is not a specialized array, it could be \"shared\" by specifying a new interval $D_B$ as the domain of "
             "a new array $B$ and an affine map $T_{BA}:D_B\\to D_A$.  Each call to $B$ would then be computed as $B(\\vec i)=A(T_{BA}(\\vec i))$.")
        (<p> "One could again \"share\" $B$, given a new interval $D_C$ as the domain of a new array $C$ and an affine transform $T_{CB}:D_C\\to D_B$, and then each access $C(\\vec i)=A(T_{BA}(T_{CB}(\\vec i)))$.  The composition $T_{BA}\\circ T_{CB}:D_C\\to D_A$, being itself affine, could be precomputed and stored as $T_{CA}:D_C\\to D_A$, and $C(\\vec i)=A(T_{CA}(\\vec i))$ could be computed with the overhead of computing a single affine transformation.")
        (<p> "So, if we wanted, we could share generalized arrays with constant overhead by adding a single layer of (multi-valued) affine transformations on top of evaluating generalized arrays.  Even though this could be done transparently to the user, we do not do that here; it would be a compatible extension of this SRFI to do so.  We provide only the procedure "(<code>'specialized-array-share)", not a more general "(<code>'array-share)".")
        (<p> "Certain ways of sharing generalized arrays, however, are relatively easy to code and are not expensive.  If we denote "(<code>"(array-getter "(<var>'A)")")" by "(<code>(<var>'A_))", then if "(<code>(<var>'B))" is the result of "(<code>'array-extract)" applied to "(<code>(<var>'A))", then "
             (<code>"(array-getter "(<var>'B)")")" is simply "(<code>(<var>'A_))".  Similarly, if "(<code>(<var>'A))" is a two-dimensional array, and "(<code>(<var>'B))" is derived from "(<code>(<var>'A))" by applying the permutation $\\pi((i,j))=(j,i)$, then "(<code>"(array-getter "(<var>'B)")")" is "
             (<code>"(lambda (i j) ("(<var>'A_)" j i))")".  Translation and currying also lead to transformed arrays whose getters are relatively efficiently derived from "(<code>(<var>'A_))", at least for arrays of small dimension.")
        (<p> "Thus, while we do not provide for sharing of generalized arrays for general one-to-one affine maps $T$, we do allow it for the specific procedures "(<code>'array-extract)", "(<code>'array-translate)", "(<code>'array-rebase)", "(<code>'array-permute)",  "
             (<code>'array-curry)",  "(<code>'array-reverse)", "(<code>'array-tile)", and "(<code>'array-sample)",  and we provide relatively efficient implementations of these procedures for arrays of dimension no greater than four.")

        (<h3> (<a> id: "array-broadcasting" "Array broadcasting"))
        (<p> "So-called \"array broadcasting\" has been found of use in several areas of array processing, and is implemented in Python's "(<a> href: "https://numpy.org/doc/stable/user/basics.broadcasting.html" "NumPy library")" and Racket's "(<a> href: "https://docs.racket-lang.org/math/array_broadcasting.html" "math/array library")";  we implement array broadcasting in the style of NumPy or math/array.  As such, we will limit our description to how the implementation of array broadcasting in this SRFI followup differs from that in NumPy or math/racket.")

        (<p> "Arrays in both Python's NumPy library and Racket's math/array library  have only zero lower bounds on indices, and while Racket has what we call generalized arrays, NumPy does not.
  Additionally, Racket allows what it calls \"permissive\" broadcasting.
So we had to make some decisions about how to broadcast generalized arrays and arrays with nonzero lower bounds.")

        (<p> "We decided:")
        (<ul>
         (<li> "Axes added at the left of an array's domain through broadcasting have lower bounds 0 and upper bounds 1.")
         (<li> "Axes with nonzero lower bounds cannot be expanded in broadcasting.")
         (<li> "Generalized arrays can be broadcast only to new intervals with the same volume (so, effectively, can be modified only by adding axes on the left), returning a generalized array.
  This restricts broadcasting of generalized arrays to 1-1 mappings of indices to avoid surprises when those broadcast arrays are \"consumed\" by some later operation.")
         (<li> "We don't allow Racket's \"permissive\" broadcasting, which requires a non-affine mapping of indices that is not composable with other (affine) array transformations.")
         (<li> "If a specialized array is broadcast to an interval with more elements (of greater volume), which, mathematically, is the result of a many-to-one mapping of indices, then the resulting array is set to be immutable.  Setting the array result to be immutable avoids the problem with non-1-1 mappings described "(<a> href: "#extension" "here")"."))

        (<h4> (<a> id: "explicit-array-broadcasting" "Explicit array broadcasting"))
        (<p> "We provide the procedure "(<code>"("(<a> href: "#compute-broadcast-interval" "compute-broadcast-interval")(<var>" I_1 I_2 ...")")")" that takes intervals as arguments.  If these intervals are domains of arrays, then "(<code>'compute-broadcast-interval)" returns either an interval (the common broadcast domain of the arrays) or "(<code>'#f)", if there is no common broadcast domain.")
        (<p> "We also provide the procedure "(<code>"("(<a> href: "#array-broadcast" "array-broadcast")(<var>" A new-domain")")")", which explicitly broadcasts an array to a compatible domain.")

        (<h4> (<a> id: "implicit-array-broadcasting" "Implicit array broadcasting"))
        (<p> "Array arguments to the procedures "
             (<code>(<a> href: "#array-map" 'array-map))", "
             (<code>(<a> href: "#array-for-each" 'array-for-each))", "
             (<code>(<a> href: "#array-every" 'array-every))", "
             (<code>(<a> href: "#array-any" 'array-any))", "
             (<code>(<a> href: "#array-fold-left" 'array-fold-left))", and "
             (<code>(<a> href: "#array-fold-right" 'array-fold-right))
             " will automatically and implicitly be broadcast to a common domain if the parameter "
             (<code>'array-broadcasting?)" is "(<code> #t)" at the time the procedure is called. If the value of that parameter is "(<code> #f)
             ", then the array arguments to these procedures are required to have the same domains.")
        (<p> "The implicit broadcasting of array arguments works as follows.  If the array arguments to one of these procedures are collected into a list called "
             (<cv>'As)", then  "(<code>"(apply compute-broadcast-interval (map array-domain "(<var>'As)"))")", the common broadcast domain of the array arguments, is computed, which we'll call "(<cv>'ND)" for \"new domain\". "
             "The list of array arguments "(<cv>'As)" is then replaced with "(<code>"(map (lambda (A) (array-broadcast "(<var>"A ND")")) "(<var>'As)")")
             ", the array arguments broadcast to "(<cv>'ND)".  It is an error if any part of this process fails due to incompatible domains.")

        (<h3> (<a> id: "convention" "Notational convention"))
        (<p> "If "(<code>(<var>'A))" is an array, then we generally define "(<code>(<var>'A_))" to be "(<code>"(array-getter "(<var>'A)")")" and  "(<code>(<var>'A!))" to be "(<code>"(array-setter "(<var>'A)")")".  The latter notation is motivated by the general Scheme convention that the names of procedures that modify the contents of data structures end in "(<code>(<var>"!"))", while the notation for the getter of an array is motivated by the TeX notation for subscripts.  See particularly the "(<a> href: "#Haar" "Haar transform")" example.")

        (<h2> (<a> id: "Notes" "Notes"))
        (<ul>
         (<li> (<b> "Empty and zero-dimensional arrays: ")"The vectors of upper and lower bounds of an interval can have zero elements, in which case the zero-dimensional interval itself has no elements, but zero-dimensional arrays with this domain have getters and setters that take zero indices as arguments, and which return or set a single element, much like a Scheme "(<code>'box)".  If an interval has at least one upper and lower bound, and at least one of these upper bounds equals the associated lower bound, then that interval is empty, and arrays with empty intervals as domains have getters and setters that should raise an exception when called.")
         (<li> (<b> "This SRFI and "(<code>'call-with-current-continuation)": ")"The Scheme procedure "(<code>'call-with-current-continuation)" captures and encapsulates as a procedure the continuation of the current computation, which, perforce, includes a certain amount of state that consists of the values of captured variables at the point the continuation is captured. This captured procedure can be invoked multiple times, as any procedure can."
               (<br>)
               "No procedure in the sample implementation itself calls "(<code>'call-with-current-continuation)", but the procedural arguments to, e.g., "(<code>'make-array)", "(<code>'specialized-array-share)", "(<code>'array-map)", etc., may themselves call "(<code>'call-with-current-continuation)"."
               (<br>)
               "All procedures in the sample implementation whose names do not end with an exclamation point (!) are written in a way that does not modify the state of any data captured by a continuation. We call such procedures "(<i>"call/cc safe")"."
               (<br>)
               "It is intended that all procedures in this library whose names do not end with an exclamation point (!) be implemented in a call/cc-safe way."
               (<br>)
               "Besides the procedures "(<code>'array-set!)" and "(<code>'array-assign!)", which explicitly mutate state and which, therefore, are "(<i>'not)" call/cc safe, we provide the procedures "(<code>'array-copy!)", "(<code>'array-stack!)", "(<code>'array-decurry!)", "(<code>'array-append!)", and "(<code>'array-block!)", which are not necessarily call/cc safe, but which may be faster or use less memory than the corresponding call/cc-safe versions."
               (<br> id: "array-assign-erratum")
               "For the procedures "(<code>'array-copy!)", "(<code>'array-stack!)", "(<code>'array-decurry!)", "(<code>'array-append!)", and "(<code>'array-block!)", it is an error if the continuation of each call to an array's getter is invoked more than once.  For the procedure "(<code>'array-assign!)", it is an error if the continuation of each call to the destination's setter or the source's getter is invoked more than once.")
         (<li> (<b> "Relationship to "(<a> href: "https://docs.racket-lang.org/math/array_nonstrict.html#%28tech._nonstrict%29" "nonstrict arrays")" in Racket. ")
               "It appears that what we call simply arrays in this SRFI are called nonstrict arrays in the math/array library of Racket, which in turn was influenced by an "(<a> href: "https://www.microsoft.com/en-us/research/wp-content/uploads/2016/07/RArrays.pdf" "array proposal for Haskell")".  Our \"specialized\" arrays are related to Racket's \"strict\" arrays.")
         (<li> (<b> "Indexers. ")"The argument "(<code>(<var> "new-domain->old-domain"))" to "(<code> 'specialized-array-share)" is, conceptually, the getter of a multi-valued array.")
         (<li> (<b> "Source of procedure names. ")"The procedure "(<code> 'array-curry)" gets its name from the" #\newline
               (<a> href: "https://en.wikipedia.org/wiki/Currying" "curry operator")
               " in programming" (string (integer->char 8212)) "we are currying the getter of the array and keeping careful track of the domains." #\newline
               (<code>'interval-projections)" can be thought of as currying the" #\newline
               "characteristic procedure of the interval,  encapsulated here as "(<code> 'interval-contains-multi-index?)".")
         (<li> (<b> "Choice of procedures on intervals. ")"The choice of procedures for both arrays and intervals was motivated almost solely by what I needed for arrays.")
         (<li> (<b> "Multi-valued arrays. ")"While this SRFI restricts attention to single-valued arrays, wherein the getter of each array returns a single value, allowing multi-valued immutable arrays would be a compatible extension of this SRFI.")
         )
        (<h2> (<a> id: "Specification" "Specification"))
        (let ((END ",\n"))
          (<p> "Names defined in this SRFI:")
          (<dl>
           (<dt> "Miscellaneous Procedures")
           (<dd> (<a> href: "#translation?" "translation?") END
                 (<a> href: "#permutation?" "permutation?") END
                 (<a> href: "#index-rotate" "index-rotate") END
                 (<a> href: "#index-first" "index-first") END
                 (<a> href: "#index-last" "index-last") END
                 (<a> href: "#index-swap" "index-swap")
                 ".")
           (<dt> "Intervals")
           (<dd> (<a> href: "#make-interval" "make-interval")END
                 (<a> href: "#interval?" "interval?")END
                 (<a> href: "#interval-dimension" "interval-dimension")END
                 (<a> href: "#interval-lower-bound" "interval-lower-bound")END
                 (<a> href: "#interval-upper-bound" "interval-upper-bound")END
                 (<a> href: "#interval-width" "interval-width")END
                 (<a> href: "#interval-lower-bounds-rarrow-list" "interval-lower-bounds->list")END
                 (<a> href: "#interval-upper-bounds-rarrow-list" "interval-upper-bounds->list")END
                 (<a> href: "#interval-lower-bounds-rarrow-vector" "interval-lower-bounds->vector")END
                 (<a> href: "#interval-upper-bounds-rarrow-vector" "interval-upper-bounds->vector")END
                 (<a> href: "#interval=" "interval=")END
                 (<a> href: "#interval-widths" "interval-widths")END
                 (<a> href: "#interval-volume" "interval-volume")END
                 (<a> href: "#interval-empty?" "interval-empty?")END
                 (<a> href: "#interval-subset?" "interval-subset?")END
                 (<a> href: "#interval-contains-multi-index?" "interval-contains-multi-index?")END
                 (<a> href: "#interval-projections" "interval-projections")END
                 (<a> href: "#interval-for-each" "interval-for-each")END
                 (<a> href: "#interval-fold-left" "interval-fold-left")END
                 (<a> href: "#interval-fold-right" "interval-fold-right")END
                 (<a> href: "#interval-dilate" "interval-dilate")END
                 (<a> href: "#interval-intersect" "interval-intersect")END
                 (<a> href: "#interval-insert-axis" "interval-insert-axis")END
                 (<a> href: "#compute-broadcast-interval" "compute-broadcast-interval")END
                 (<a> href: "#interval-translate" "interval-translate")END
                 (<a> href: "#interval-rebase" "interval-rebase")END
                 (<a> href: "#interval-permute" "interval-permute") END
                 (<a> href: "#interval-scale" "interval-scale") END
                 (<a> href: "#interval-cartesian-product" "interval-cartesian-product")
                 ".")
           (<dt> "Storage Classes")
           (<dd> (<a> href: "#make-storage-class" "make-storage-class") END
                 (<a> href: "#storage-class?" "storage-class?") END
                 (<a> href: "#storage-class-getter" "storage-class-getter") END
                 (<a> href: "#storage-class-setter" "storage-class-setter") END
                 (<a> href: "#storage-class-checker" "storage-class-checker") END
                 (<a> href: "#storage-class-maker" "storage-class-maker") END
                 (<a> href: "#storage-class-copier" "storage-class-copier") END
                 (<a> href: "#storage-class-length" "storage-class-length") END
                 (<a> href: "#storage-class-default" "storage-class-default") END
                 (<a> href: "#storage-class-data?" "storage-class-data?") END
                 (<a> href: "#storage-class-data-rarrow-body" "storage-class-data->body") END
                 (<a> href: "#generic-storage-class" "generic-storage-class") END
                 (<a> href: "#char-storage-class" "char-storage-class") END
                 (<a> href: "#s8-storage-class" "s8-storage-class") END
                 (<a> href: "#s16-storage-class" "s16-storage-class") END
                 (<a> href: "#s32-storage-class" "s32-storage-class") END
                 (<a> href: "#s64-storage-class" "s64-storage-class") END
                 (<a> href: "#u1-storage-class" "u1-storage-class") END
                 (<a> href: "#u8-storage-class" "u8-storage-class") END
                 (<a> href: "#u16-storage-class" "u16-storage-class") END
                 (<a> href: "#u32-storage-class" "u32-storage-class") END
                 (<a> href: "#u64-storage-class" "u64-storage-class") END
                 (<a> href: "#f8-storage-class" "f8-storage-class") END
                 (<a> href: "#f16-storage-class" "f16-storage-class") END
                 (<a> href: "#f32-storage-class" "f32-storage-class") END
                 (<a> href: "#f64-storage-class" "f64-storage-class") END
                 (<a> href: "#c64-storage-class" "c64-storage-class") END
                 (<a> href: "#c128-storage-class" "c128-storage-class")
                 ".")
           (<dt> "Arrays")
           (<dd> (<a> href: "#specialized-array-default-mutable?" "specialized-array-default-mutable?") END
                 (<a> href: "#array-broadcasting?" "array-broadcasting?") END
                 (<a> href: "#make-array" "make-array")END
                 (<a> href: "#array?" "array?")END
                 (<a> href: "#array-domain" "array-domain")END
                 (<a> href: "#array-getter" "array-getter")END
                 (<a> href: "#array-dimension" "array-dimension")END
                 (<a> href: "#mutable-array?" "mutable-array?")END
                 (<a> href: "#array-setter" "array-setter")END
                 (<a> href: "#array-empty?" "array-empty?")END
                 (<a> href: "#make-specialized-array" "make-specialized-array")END
                 (<a> href: "#make-specialized-array-from-data" "make-specialized-array-from-data")END
                 (<a> href: "#specialized-array?" "specialized-array?")END
                 (<a> href: "#array-storage-class" "array-storage-class")END
                 (<a> href: "#array-indexer" "array-indexer")END
                 (<a> href: "#array-body" "array-body")END
                 (<a> href: "#array-packed?" "array-packed?") END
                 (<a> href: "#specialized-array-share" "specialized-array-share")END
                 (<a> href: "#array-copy" "array-copy")END
                 (<a> href: "#array-copy!" "array-copy!")END
                 (<a> href: "#array-curry" "array-curry")END
                 (<a> href: "#array-extract" "array-extract") END
                 (<a> href: "#array-tile" "array-tile") END
                 (<a> href: "#array-translate" "array-translate")END
                 (<a> href: "#array-rebase" "array-rebase")END
                 (<a> href: "#array-permute" "array-permute")END
                 (<a> href: "#array-reverse" "array-reverse")END
                 (<a> href: "#array-sample" "array-sample")END
                 (<a> href: "#array-insert-axis" "array-insert-axis")END
                 (<a> href: "#array-broadcast" "array-broadcast")END
                 (<a> href: "#array-outer-product" "array-outer-product") END
                 (<a> href: "#array-inner-product" "array-inner-product") END
                 (<a> href: "#array-map" "array-map")END
                 (<a> href: "#array-for-each" "array-for-each")END
                 (<a> href: "#array-fold-left" "array-fold-left")END
                 (<a> href: "#array-fold-right" "array-fold-right")END
                 (<a> href: "#array-reduce" "array-reduce") END
                 (<a> href: "#array-any" "array-any")END
                 (<a> href: "#array-every" "array-every")END
                 (<a> href: "#array-rarrow-list" "array->list") END
                 (<a> href: "#list-rarrow-array" "list->array") END
                 (<a> href: "#array-rarrow-list*" "array->list*") END
                 (<a> href: "#list*-rarrow-array" "list*->array") END
                 (<a> href: "#object-rarrow-array" "object->array") END
                 (<a> href: "#array-rarrow-vector" "array->vector") END
                 (<a> href: "#vector-rarrow-array" "vector->array") END
                 (<a> href: "#vector*-rarrow-array" "vector*->array") END
                 (<a> href: "#array-rarrow-vector*" "array->vector*") END
                 (<a> href: "#array-assign!" "array-assign!") END
                 (<a> href: "#array-stack" "array-stack") END
                 (<a> href: "#array-stack!" "array-stack!") END
                 (<a> href: "#array-decurry" "array-decurry") END
                 (<a> href: "#array-decurry!" "array-decurry!") END
                 (<a> href: "#array-append" "array-append") END
                 (<a> href: "#array-append!" "array-append!") END
                 (<a> href: "#array-block" "array-block") END
                 (<a> href: "#array-block!" "array-block!") END
                 (<a> href: "#array-ref" "array-ref") END
                 (<a> href: "#array-set!" "array-set!") END
                 (<a> href: "#specialized-array-reshape" "specialized-array-reshape")
                 "."
                 )))
        (<h2> (<a> id: "Preliminary" "Preliminary notes"))
        (<p> "We use "(<code>'take)" and "(<code>'drop)" from "(<a> href: "https://srfi.schemers.org/srfi-1/srfi-1.html" "SRFI 1")" to define various procedures.")
        (<h2> (<a> id: "Miscellaneous" "Miscellaneous procedures"))
        (<p> "This document refers to "(<i> 'translations)" and "(<i> 'permutations)".
 A translation is a vector of exact integers.  A permutation of dimension $n$
is a vector whose entries are the exact integers $0,1,\\ldots,n-1$, each occurring once, in any order.
We provide four procedures that return useful permutations.")
        (<h3> (<a> id: "miscprocedures" "Procedures"))
        (format-lambda-list '(translation? object))
        (<p> "Returns "(<code> '#t)" if "(<code>(<var>'object))" is a translation, and "(<code> '#f)" otherwise.")
        (format-lambda-list '(permutation? object))
        (<p> "Returns "(<code> '#t)" if "(<code>(<var>'object))" is a permutation, and "(<code> '#f)" otherwise.")
        (format-lambda-list '(index-rotate n k))
        (<p> "Assumes that "(<var>'n)" is a nonnegative exact integer and that "(<var>'k)" is an exact integer between 0 and "(<var>'n)" (inclusive).   Returns a permutation that rotates "(<var>'n)" indices "(<var>'k)" places to the left:")
        (<pre>(<code>
"(define (index-rotate n k)
  (let ((identity-permutation (iota n)))
    (list->vector (append (drop identity-permutation k)
                          (take identity-permutation k)))))"))
        (<p> "For example, "(<code>"(index-rotate 5 3)")" returns "(<code>"'#(3 4 0 1 2)")". It is an error of the arguments do not satisfy these conditions.")
        (format-lambda-list '(index-first n k))
        (<p> "Assumes that "(<var>'n)" is a positive exact integer and that "(<var>'k)" is an exact integer between 0 (inclusive) and "(<var>'n)" (exclusive).  Returns a permutation of length "(<var>'n)" that moves index "(<var>'k)" (with count beginning at 0) to be first and leaves the other indices in order:")
        (<pre>(<code>
"(define (index-first n k)
  (let ((identity-permutation (iota n)))
    (list->vector (cons k
                        (append (take identity-permutation k)
                                (drop identity-permutation (fx+ k 1)))))))"))
        (<p> "For example, "(<code>"(index-first 5 3)")" returns "(<code>"'#(3 0 1 2 4)")". It is an error if the arguments do not satisfy these conditions.")
        (format-lambda-list '(index-last n k))
        (<p> "Assumes that "(<var>'n)" is a positive exact integer and that "(<var>'k)" is an exact integer between 0 (inclusive) and "(<var>'n)" (exclusive).  Returns a permutation of length "(<var>'n)" that moves index "(<var>'k)" (with count beginning at 0) to be last and leaves the other indices in order:")
        (<pre>(<code>
"(define (index-last n k)
  (let ((identity-permutation (iota n)))
    (list->vector (append (take identity-permutation k)
                          (drop identity-permutation (fx+ k 1))
                          (list k)))))"))
        (<p> "For example, "(<code>"(index-last 5 3)")" returns "(<code>"'#(0 1 2 4 3)")". It is an error if the arguments do not satisfy these conditions.")
        (format-lambda-list '(index-swap n i j))
        (<p> "Assumes that "(<code>(<var>'n))" is a positive exact integer and that "(<code>(<var>'i))" and "(<code>(<var>'j))" are exact integers between 0 (inclusive) and "(<code>(<var>'n))" (exclusive). Returns a permutation of length "(<code>(<var>'n))" that swaps index "(<code>(<var>'i))" and index "(<code>(<var>'j))" and leaves the other indices in order.")
        (<p> "For example, "(<code>"(index-swap 5 3 0)")" returns "(<code>"#(3 1 2 0 4)")". It is an error if the arguments do not satisfy these assumptions.")

(<h2> (<a> id: "Intervals" "Intervals"))
        (<p> "An interval represents the set of all multi-indices of exact integers
$i_0,\\ldots,i_{d-1}$
satisfying
$l_0\\leq i_0<u_0,\\ldots,l_{d-1}\\leq i_{d-1}<u_{d-1}$,
where the "(<i>"lower bounds")"
$l_0,\\ldots,l_{d-1}$
and the "(<i>"upper bounds")"
$u_0,\\ldots,u_{d-1}$
are exact integers.  The nonnegative integer $d$ is the "(<i>"dimension")"
of the interval.")
        (<p> "If $l_k=u_k$ for some $k$ then the interval is "(<i>'empty)"; if $d=0$ then the interval is "(<i>'zero-dimensional)".  So rather than mathematical objects, it is perhaps better to think of intervals as pairs of vectors $L$ and $U$ for which $L_k\\leq U_k$; $L$ or $U$ could be empty (hence $d=0$).")
        (<p> "Intervals are a data type distinct from other Scheme data types.")

        (<h3> (<a> id: "intervalprocedures" "Procedures"))
        (format-lambda-list '(make-interval arg1 #!optional arg2))
        (<p> "Create a new interval. Assumes that "(<code> (<var>"arg1"))" and "(<code> (<var>"arg2"))" (if given) are vectors (of the same length) of exact integers.")
        (<p> "If "(<code> (<var>"arg2"))" is not given, then the entries of "(<code> (<var>"arg1"))", if any, must be nonnegative, and they are taken as the "(<code>(<var>"upper-bounds"))" of the interval, and  "(<code> (<var>"lower-bounds"))" is set to a vector of the same length with exact zero entries.")
        (<p> "If "(<code> (<var>"arg2"))" is given, then "(<code> (<var>"arg1"))" is taken to be "(<code> (<var>"lower-bounds"))" and "(<code> (<var>"arg2"))" is taken to be "(<code> (<var>"upper-bounds"))", which must satisfy")
        (<pre>
         (<code>"(<= (vector-ref "(<var>"lower-bounds")" i) (vector-ref "(<var>"upper-bounds")" i))"))
        (<p> " for
$0\\leq i<{}$"(<code>"(vector-length "(<var>"lower-bounds")")")".  It is an error if
"(<code>(<var>"lower-bounds"))" and "(<code>(<var>"upper-bounds"))" do not satisfy these conditions.")
        (<p> (<b> "Example: "))(<pre>(<code>"(let ((A (make-interval '#(3 4)))
      (B (make-interval '#(0 0) '#(3 4))))
  (interval= A B))   ;; => #t"))

        (format-lambda-list '(interval? object))
        (<p> "Returns "(<code> "#t")" if "(<code> (<var>"object"))" is an interval, and "(<code>"#f")" otherwise.")
        (<p> (<b> "Example: "))(<pre>(<code>"(let ((A (make-interval '#(3 4)))
      (B 1))
  (interval? A)      ;; => #t
  (interval? B))     ;; => #f"))

        (format-lambda-list '(interval-dimension interval))
        (<p> "Assumes "(<code>(<var>"interval"))" is an interval; if "(<code>(<var>'interval))" is built with ")
        (<pre>
         (<code>"(make-interval "(<var>"lower-bounds")" "(<var>"upper-bounds")")"))
        (<p> "then "(<code> 'interval-dimension)" returns "(<code>"(vector-length "(<var>"lower-bounds")")")".")
        (<p> "It is an error to call "(<code> 'interval-dimension)"
if "(<code>(<var>"interval"))" is not an interval.")
        (<p> (<b> "Example: "))(<pre>(<code>"(let ((A (make-interval '#(3 4)))
      (B (make-interval '#())))
  (interval-dimension A)   ;; => 2
  (interval-dimension B))  ;; => 0"))

        (format-lambda-list '(interval-lower-bound interval i))
        (format-lambda-list '(interval-upper-bound interval i))
        (format-lambda-list '(interval-width       interval i))
        (<p> "Assumes that "(<code>(<var>"interval"))" is an interval made, e.g., with "(<code>"(make-interval "(<var>"lower-bounds upper-bounds")")")", and that "(<code>(<var>'i))" is an exact integer that satisfies")
        (<blockquote>
         "$0 \\leq i<$ "(<code>"(interval-dimension "(<var>"interval")")")".")
        (<p> " Then "(<code> 'interval-lower-bound)" returns
"(<code>"(vector-ref "(<var>"lower-bounds")" "(<var>"i")")")", "(<code> 'interval-upper-bound)" returns
"(<code>"(vector-ref "(<var>"upper-bounds")" "(<var>"i")")")", and "(<code>'interval-width)" returns
"(<code>"(- (vector-ref "(<var>'upper-bounds)" "(<var>'i)") (vector-ref "(<var>'lower-bounds)" "(<var>'i)"))")".")
        (<p> "It is an error to call "(<code> 'interval-lower-bound)", "(<code> 'interval-upper-bound)", or "
             (<code>'interval-width)" if "(<code>(<var>"interval"))" and "(<code>(<var>"i"))" do not satisfy these conditions.")
        (<p> (<b> "Example: "))(<pre>(<code>"(let ((A (make-interval '#(1 0) '#(3 4))))
  (interval-lower-bound A 0)  ;; => 1
  (interval-upper-bound A 0)  ;; => 3
  (interval-width A 0))       ;; => 2"))

        (format-lambda-list '(interval-lower-bounds->list interval) 'interval-lower-bounds-rarrow-list)
        (format-lambda-list '(interval-upper-bounds->list interval) 'interval-upper-bounds-rarrow-list)
        (<p> "Assumes "(<code>(<var>"interval"))" is an interval built, e.g., by ")
        (<pre>
         (<code>"(make-interval "(<var>"lower-bounds")" "(<var>"upper-bounds")")"))
        (<p> "Then "(<code> 'interval-lower-bounds->list)" returns "(<code> "(vector->list "(<var>"lower-bounds")")")
             " and  "(<code> 'interval-upper-bounds->list)" returns "(<code> "(vector->list "(<var>"upper-bounds")")")".")
        (<p> "It is an error to call
 "(<code> 'interval-lower-bounds->list)" or "(<code> 'interval-upper-bounds->list)" if "(<code>(<var>"interval"))" does not satisfy these conditions.")
        (<p> (<b> "Example: "))(<pre>(<code>"(let ((A (make-interval '#(1 0) '#(3 4))))
  (interval-lower-bounds->list A)   ;; => (1 0)
  (interval-upper-bounds->list A))  ;; => (3 4)"))

        (format-lambda-list '(interval-lower-bounds->vector interval) 'interval-lower-bounds-rarrow-vector)
        (format-lambda-list '(interval-upper-bounds->vector interval) 'interval-upper-bounds-rarrow-vector)
        (<p> "Assumes "(<code>(<var>"interval"))" is an interval built, e.g., with ")
        (<pre>
         (<code>"(make-interval "(<var>"lower-bounds")" "(<var>"upper-bounds")")"))
        (<p> "Then "(<code> 'interval-lower-bounds->vector)" returns a copy of "(<code> (<var>"lower-bounds"))
             "  and "(<code> 'interval-upper-bounds->vector)" returns a copy of "(<code> (<var>"upper-bounds"))".")
        (<p> "It is an error to call
"(<code> 'interval-lower-bounds->vector)" or "(<code> 'interval-upper-bounds->vector)" if "(<code>(<var>"interval"))" does not satisfy these conditions.")
        (<p> (<b> "Example: "))(<pre>(<code>"(let ((A (make-interval '#(1 0) '#(3 4))))
  (interval-lower-bounds->vector A)   ;; => '#(1 0)
  (interval-upper-bounds->vector A))  ;; => '#(3 4)"))

        (format-lambda-list '(interval-widths interval))
        (<p> "Assumes "(<code>(<var>"interval"))" is an interval built, e.g., with ")
        (<pre>
         (<code>"(make-interval "(<var>"lower-bounds")" "(<var>"upper-bounds")")"))
        (<p> "Then, assuming the existence of "(<code>'vector-map)", "(<code> 'interval-widths)" returns ")
        (<pre>
         (<code> "(vector-map - "(<var>"upper-bounds")" "(<var>"lower-bounds")")"))
        (<p> "It is an error to call "(<code> 'interval-widths)" if "(<code>(<var> 'interval))" does not satisfy this condition.")
        (<p> (<b> "Example: "))(<pre>(<code>"(let ((A (make-interval '#(1 0) '#(3 4))))
  (interval-widths A))     ;; => '#(2 4)"))

        (format-lambda-list '(interval-volume interval))
        (<p> "Assumes "(<code>(<var>"interval"))" is an interval built, e.g., with ")
        (<pre>
         (<code>"(make-interval "(<var>"lower-bounds")" "(<var>"upper-bounds")")"))
        (<p> "Then, assuming the existence of "(<code>'vector-map)", "(<code> 'interval-volume)" returns ")
        (<pre>
         (<code> "(apply * (vector->list (vector-map - "(<var>"upper-bounds")" "(<var>"lower-bounds")")))"))
        (<p> "It is an error to call "(<code> 'interval-volume)" if "(<code>(<var> 'interval))" does not satisfy this condition.")
        (<p> (<b> "Example: "))(<pre>(<code>"(let ((A (make-interval '#(1 0) '#(3 4)))
      (B (make-interval '#())))
  (interval-volume A)    ;; => 8
  (interval-volume B))   ;; => 1"))

        (format-lambda-list '(interval-empty? interval))
        (<p> "Assumes "(<code>(<var>'interval))" is an interval; returns "(<code>"(eqv? 0 (interval-volume "(<var>'interval)"))")".")
        (<p> "It is an error to call "(<code> 'interval-empty?)" if "(<code>(<var> 'interval))" does not satisfy this condition.")
        (<p> (<b> "Example: "))(<pre>(<code>"(let ((A (make-interval '#(1 0) '#(3 4)))
      (B (make-interval '#()))
      (C (make-interval '#(1 0) '#(1 4))))
  (interval-empty? A)     ;; => #f
  (interval-empty? B)     ;; => #f
  (interval-empty? C))    ;; => #t"))

        (format-lambda-list '(interval= interval1 interval2))
        (<p> "Assumes that "(<code>(<var>"interval1"))" and "(<code>(<var>"interval2"))" are intervals built, e.g., with ")
        (<pre>
         (<code>"(make-interval "(<var>"lower-bounds1")" "(<var>"upper-bounds1")")"))
        (<p> "and")
        (<pre>
         (<code>"(make-interval "(<var>"lower-bounds2")" "(<var>"upper-bounds2")")"))
        (<p> "respectively. Then "(<code> 'interval=)" returns")
        (<pre>
         (<code> "(and (equal? "(<var> 'lower-bounds1)" "(<var> 'lower-bounds2)") (equal? "(<var> 'upper-bounds1)" "(<var> 'upper-bounds2)"))"))
        (<p> "It is an error to call "(<code> 'interval=)" if "(<code>(<var> 'interval1))" or "(<code>(<var> 'interval2))" do not satisfy this condition.")
        (<p> (<b> "Example: "))(<pre>(<code>"(let ((A (make-interval '#(1)))
      (B (make-interval '#(1 1)))
      (C (make-interval '#(0) '#(1)))
      (D (make-interval '#(0 0)))
      (E (make-interval '#(0))))
  (interval= A B)      ;; => #f
  (interval= A C)      ;; => #t
  (interval= D E))     ;; => #f"))

        (format-lambda-list '(interval-subset? interval1 interval2))
        (<p> "Assumes that "(<code>(<var>"interval1"))" and "(<code>(<var>"interval2"))" are intervals of the same dimension $d$. "
             "Then "(<code>'interval-subset?)" returns "(<code>'#t)" if ")
        (<pre>
         (<code>"(>= (interval-lower-bound "(<var>'interval1)" j) (interval-lower-bound "(<var>'interval2)" j))"))
        (<p> "and")
        (<pre>
         (<code>"(<= (interval-upper-bound "(<var>'interval1)" j) (interval-upper-bound "(<var>'interval2)" j))"))
        (<p> "for all $0\\leq j<d$.  Otherwise, it returns "(<code>'#f)".  It is an error if the arguments do not satisfy these conditions.")
        (<p> (<b> "Example: "))(<pre>(<code>"(let ((A (make-interval '#(2 3)))
      (B (make-interval '#(1 1)))
      (C (make-interval '#(3 1) '#(3 3))))
  (interval-subset? A B)   ;; => #f
  (interval-subset? B A)   ;; => #t
  (interval-subset? C A))  ;; => #f"))

        (format-lambda-list '(interval-contains-multi-index? interval #\. multi-index))
        (<p> "Assumes that "(<code>(<var> 'interval))" is an interval with dimension $d$ and "(<code>(<var>'multi-index))" is a multi-index (a sequence of exact integers) of length $d$. Then "(<code> 'interval-contains-multi-index?)" returns "(<code>"(every <= (interval-lower-bounds->list "(<var>'interval)") "(<var>'multi-index)" (interval-upper-bounds->list "(<var>'interval)"))")".")
        (<p> "It is an error to call "(<code> 'interval-contains-multi-index?)" if "(<code>(<var> 'interval))" and "(<code>(<var> 'multi-index))" do not satisfy this condition.")
        (<p> (<b> "Example: "))(<pre>(<code>"(let ((A (make-interval '#(1 0) '#(4 5))))
  (interval-contains-multi-index? A 2 1)   ;; => #t
  (interval-contains-multi-index? A 0 3))  ;; => #f"))

        (format-lambda-list '(interval-projections interval right-dimension))
        (<p> "Conceptually, "(<code> 'interval-projections)" takes a $d$-dimensional interval
$[l_0,u_0)\\times [l_1,u_1)\\times\\cdots\\times[l_{d-1},u_{d-1})$\n"
             "and splits it into two parts")
        (<blockquote> "$[l_0,u_0)\\times\\cdots\\times[l_{d-\\text{right-dimension}-1},u_{d-\\text{right-dimension}-1})$")
        (<p> "and")
        (<blockquote> "$[l_{d-\\text{right-dimension}},u_{d-\\text{right-dimension}})\\times\\cdots\\times[l_{d-1},u_{d-1})$")
        (<p> "This procedure, the inverse of Cartesian products or cross products of intervals, is used to keep track of the domains of curried arrays.")
        (<p> "More precisely, this procedure assumes that  "(<code>(<var> 'interval))" is an interval and "(<code>(<var> 'right-dimension))" is an exact integer that satisfies "
             (<code> "0 <= "(<var> 'right-dimension)" <= "(<var>'d))", in which case "(<code> 'interval-projections)" returns two intervals:")
        (<pre>(<code>"(let ((left-dimension
       (- (interval-dimension interval right-dimension)))
      (lowers
       (interval-lower-bounds->list interval))
      (uppers
       (interval-upper-bounds->list interval)))
  (values
   (make-interval
    (list->vector (take lowers left-dimension))
    (list->vector (take uppers left-dimension)))
   (make-interval
    (list->vector (drop lowers left-dimension))
    (list->vector (drop uppers left-dimension)))))"))
        (<p> "It is an error to call "(<code> 'interval-projections)" if its arguments do not satisfy these conditions.")
        (<p> (<b> "Example: "))(<pre>(<code>"(let ((A (make-interval '#(2 3 1 5 4))))
  (call-with-values
      (lambda ()
        (interval-projections A 2))
    (lambda (left right)
      (interval= (make-interval '#(2 3 1)) left)    ;; => #t
      (interval= (make-interval '#(5 4)) right))))  ;; => #t"))


        (format-lambda-list '(interval-for-each f interval))
        (<p> "This procedure assumes that "(<code>(<var> 'interval))" is an interval and "(<code>(<var> 'f))" is a procedure whose domain includes elements of "(<code>(<var> 'interval))".  It is an error to call "(<code> 'interval-for-each)" if "(<code>(<var> 'interval))" and "(<code>(<var> 'f))" do not satisfy these conditions.")
        (<p>  (<code> 'interval-for-each)" calls "(<code>(<var> 'f))" with each multi-index of "(<code>(<var> 'interval))" as arguments, all in lexicographical order.")
        (<p> "In particular, if "(<code>(<var>'interval))" is zero-dimensional, "(<code>(<var>'f))" is called as a thunk; if the interval is empty, then "(<code>(<var>'f))" is never called.")
        (<p> (<b> "Example: "))(<pre>(<code>"(let ((A (make-interval '#(3 2))))
  (interval-for-each (lambda (i j)
                       (display i) (display #\\space)
                       (display j) (display #\\space)
                       (display \"=> \")
                       (display (and (even? i)
                                     (even? j)))
                       (newline))
                     A))"))
        (<p> "Displays:")
        (<pre>(<code>"0 0 => #t
0 1 => #f
1 0 => #f
1 1 => #f
2 0 => #t
2 1 => #f"))

        (format-lambda-list '(interval-fold-left  operator  left-identity interval f #\. fs))
        (format-lambda-list '(interval-fold-right operator right-identity interval f #\. fs))
        (<p> "These procedures  assume that "(<cv>'interval)" is an interval, "(<code>"(cons "(<var>"f fs")")")" is a list of $n$ procedures whose domains includes elements of "(<code>(<var>'interval))", and that "(<code>(<var>'operator))" is a procedure of $n+1$ arguments.")
        (<p> "Assume that there is a procedure "(<code>"(next-multi-index multi-index interval)")" which, given an interval and a list representing a multi-index in that interval, returns either a list representing the next valid multi-index in the interval or "(<code> #f)" if no such multi-index exists.")
        (<p> "Then these procedures can be defined as")
        (<pre>(<code>"(define (interval-fold-left operator left-identity interval f . fs)
  (if (interval-empty? interval)
      left-identity
      (let ((fs (cons f fs)))
        (let loop ((args (interval-lower-bounds->list interval))
                   (result left-identity))
          (if args
              (loop (next-multi-index args interval)
                    (apply operator result (map (lambda (f) (apply f args)) fs)))
              result)))))

(define (interval-fold-right operator right-identity interval f . fs)
  (if (interval-empty? interval)
      right-identity
      (let ((fs (cons f fs)))
        (let loop ((args (interval-lower-bounds->list interval)))
          (if args
              (let* ((items (map (lambda (f) (apply f args)) fs))
                     (result (loop (next-multi-index args interval))))
                (apply operator (append items (list result))))
              right-identity)))))"))
        (<p> "Note that "(<code>'interval-fold-left)" alternates evaluations of the procedures "(<code>"(cons "(<var>"f fs")")")" and "(<code>(<var>'operator))", while "(<code>'interval-fold-right)" evaluates the procedures "(<code>"(cons "(<var>"f fs")")")" at all multi-indices before applying "(<code>(<var>'operator))" to any arguments.")
        (<p> "It is an error if the arguments do not satisfy these assumptions.")
        (<p> (<b> "Example: ")"One can compute the "(<a> href: "https://en.wikipedia.org/w/index.php?title=Sieve_of_Eratosthenes&oldid=1101704798" "Sieve of Eratosthenes")" with ")(<pre>(<code>"(define (eratosthenes n)
  ;; Compute all primes <= n
  (let* ((sqrt-n (exact (floor (sqrt n))))
         (A (make-specialized-array (make-interval '#(2)
                                                   (vector (+ n 1)))
                                    u1-storage-class
                                    1))
         (A_ (array-getter A))
         (A! (array-setter A)))
    (do ((i 2 (+ i 1)))
        ((> i sqrt-n)
         (interval-fold-right (lambda (A_i result)
                                (if (eqv? A_i 1)
                                    (cons i result)
                                    result))
                              '()
                              (array-domain A)
                              A_))
      (if (eqv? (A_ i) 1)
          (do ((j (square i) (+ j i)))
              ((> j n))
            (A! 0 j))))))

(length (eratosthenes 1000000)) => 78498"))

        (format-lambda-list '(interval-dilate interval lower-diffs upper-diffs))
        (<p> "Assumes that "(<code>(<var> 'interval))" is an interval with
lower bounds $\\ell_0,\\dots,\\ell_{d-1}$ and
upper bounds $u_0,\\dots,u_{d-1}$, and "
             (<code>(<var> "lower-diffs"))" is a vector of exact integers $L_0,\\dots,L_{d-1}$ and "
             (<code>(<var> "upper-diffs"))" is a vector of exact integers $U_0,\\dots,U_{d-1}$. Then "
             (<code>"interval-dilate")" returns a new interval with
lower bounds $\\ell_0+L_0,\\dots,\\ell_{d-1}+L_{d-1}$ and
upper bounds $u_0+U_0,\\dots,u_{d-1}+U_{d-1}$, as long as this is a
valid interval.  It is an error if the arguments do not satisfy these conditions.")
        (<p> (<b> "Examples:"))
(<pre>(<code>"(interval=
 (interval-dilate (make-interval '#(100 100))
                  '#(1 1) '#(1 1))
 (make-interval '#(1 1) '#(101 101))) => #t
(interval=
 (interval-dilate (make-interval '#(100 100))
                  '#(-1 -1) '#(1 1))
 (make-interval '#(-1 -1) '#(101 101))) => #t
(interval=
 (interval-dilate (make-interval '#(100 100))
                  '#(0 0) '#(-50 -50))
 (make-interval '#(50 50))) => #t
(interval-dilate
 (make-interval '#(100 100))
 '#(0 0) '#(-500 -50)) => error"))

(format-lambda-list '(interval-intersect interval #\. intervals))
(<p> "Assumes that all the arguments are intervals of the same dimension.  If they have a valid intersection,
then "(<code> 'interval-intersect)" returns that intersection; otherwise it returns "(<code>'#f)".")
(<p> "More precisely, "(<code>'interval-intersect)" calculates")
(<pre>(<code>"(let* ((intervals (cons interval intervals))
       (lower-bounds (apply vector-map max (map interval-lower-bounds intervals)))
       (upper-bounds (apply vector-map min (map interval-upper-bounds intervals))))
  (and (vector-every (lambda (x y) (<= x y)) lower-bounds upper-bounds)
       (make-interval lower-bounds upper-bounds)))"))
(<p> "It is an error if the arguments are not all intervals with the same dimension.")
(<p> (<b> "Example: "))(<pre>(<code>"(let ((A (make-interval '#(2 5) '#(10 7)))
      (B (make-interval '#(0 6) '#(8 11)))
      (C (make-interval '#(2 6) '#(8 7)))
      (D (make-interval '#(1 1))))
  (interval= (interval-intersect A B) C)  ;; => #t
  (interval-intersect A D))               ;; => #f"))

(format-lambda-list '(interval-insert-axis interval k #\[ u_k #\]))
(<p> "Assumes that "(<code>(<var>'interval))" is an interval, "(<code>(<var>'k))" is an exact integer between 0 and "(<code>"(interval-dimension interval)")", inclusive, and that "(<code>(<var>'u_k))", if given, is a positive exact integer.  If omitted, "(<code>(<var>'u_k))" is assumed to be 1.")
(<p> "Returns a new interval, copying the upper and lower bounds of "(<code>(<var>'interval))" except that a new "(<code>(<var>'k))"th axis with lower bound 0 and upper bound "(<code>(<var>'u_k))" is inserted among the existing axes of "(<code>(<var>'interval))".")
(<p>"It is an error if the arguments do not satisfy these assumptions.")
(<p>(<b> "Example: ")(<pre>(<code>"((let ((A (make-interval '#(2 5) '#(10 7)))
       (B (make-interval '#(2 0 5) '#(10 1 7)))
       (C (make-interval '#(2 0 5) '#(10 6 7))))
   (interval= (interval-insert-axis A 1) B)    ;; => #t
   (interval= (interval-insert-axis A 1 6) C))   ;; => #t")))

(format-lambda-list '(compute-broadcast-interval I #\. Irest))
(<p> "Assumes that "(<cv>'I)" is an interval and "(<code>(<var>'Irest))" is a list of intervals.")
(<p> "If we interpret the arguments as the domains of arrays, then this routine computes the domain of the result of \"broadcasting\" those arrays.  This is accomplished in the following steps, after denoting "(<code>"(cons "(<var>"I Irest")")")" by "(<cv>'Is)":")
(<ol>
 (<li> "If we denote the maximum of the dimensions of the intervals in "(<code>(<var>'Is))" by $D$, then each interval "(<code>(<var>'I))" in "(<code>(<var>'Is))" has axes added to the left with "(<code>"(interval-insert-axis I 0)")" until its dimension is $D$; call the resulting list of intervals "(<code>(<var>'I*s))".")
 (<li> "If the intervals in "(<code>(<var>'I*s))" do not all have the same lower bounds, "(<code>'compute-broadcast-interval)" returns "(<code>'#f)".")
 (<li> "Otherwise, for each axis "(<code>(<var>'k))" of the intervals in "(<code>(<var>'I*s))" we compute the maximum of "(<code>"(interval-upper-bound I* k)")" over all intervals "(<code>(<var>'I*))" in "(<code>(<var>'I*s))" and denote it by $M_k$.")
 (<li> "For each axis "(<code>(<var>'k))" and for each "(<code>(<var>'I*))" in "(<code>(<var>'I*s))", we check the following: If the common "(<code>(<var>'k))"th lower bound is nonzero, then the values of "(<code>"(interval-upper-bound I* k)")" are all equal; otherwise, "(<code>"(interval-upper-bound I* k)")" is either 1 or $M_k$. If this is false, we return "(<code>'#f)", otherwise we return an interval with the common lower bounds and upper bounds $M_k$ for each "(<code>(<var>'k))"."))

(<p> (<b>"Examples: ")(<pre>(<code>"(let ((I~s (list (make-interval '#(1 2) '#(2 4))
                 (make-interval '#(2 4))))
      (I*s (list (make-interval '#(0 0 1) '#(1 4 2))
                 (make-interval '#(0 0 1) '#(3 1 2))))
      (I^s (list (make-interval '#(0 0 1) '#(3 1 2))
                 (make-interval '#(0 0 1) '#(4 4 2))))
      (I&s (list (make-interval     '#(3))
                 (make-interval '#(100 3)))))
  (apply compute-broadcast-interval I~s) ;; => #f, because of 2.
  (apply compute-broadcast-interval I*s) ;; => (make-interval '#(0 0 1) '#(3 4 2))
  (apply compute-broadcast-interval I^s) ;; => #f, because of 4.
  (apply compute-broadcast-interval I&s));; => (make-interval '#(100 3))")))

(<p>(<b> "Note: ")"We add new axes to the left, as does NumPy; Julia and Mathematica add axes on the right.")

(format-lambda-list '(interval-translate interval translation))
(<p> "Assumes that "(<code>(<var> 'interval))" is an interval, with, e.g.,
lower bounds $\\ell_0,\\dots,\\ell_{d-1}$ and
upper bounds $u_0,\\dots,u_{d-1}$, and "
(<code>(<var> "translation"))" is a translation with entries $T_0,\\dots,T_{d-1}$.
Then "
(<code>"interval-translate")" returns a new interval with
lower bounds $\\ell_0+T_0,\\dots,\\ell_{d-1}+T_{d-1}$ and
upper bounds $u_0+T_0,\\dots,u_{d-1}+T_{d-1}$.
It is an error if the arguments do not satisfy these conditions.")
(<p> "One could define "(<code> "(interval-translate interval translation)")" by "(<code> "(interval-dilate interval translation translation)")".")
(<p> (<b> "Example: "))(<pre>(<code>"(let ((A (make-interval '#(2 5) '#(10 7)))
      (B (make-interval '#(1 6) '#(9 8))))
  (interval= (interval-translate A '#(-1 1)) B))  ;; => #t"))

(format-lambda-list '(interval-rebase interval #\[ lower-bounds #\]))
(<p> "Assumes that "(<code>(<var>'interval))" is an interval and "(<code>(<var>'lower-bounds))", if given, is a vector of exact integers whose length is the same as the dimension of the first argument. "(<code>'interval-rebase)" returns a new interval which is "(<code>(<var>'interval))" translated to have lower bounds given by "(<code>(<var>'lower-bounds))".  It is an error if the arguments do not satisfy these conditions.")
(<p> (<b>"Example: "))
(<pre>"(let ((A (make-interval '#(2 5) '#(10 7)))
      (B (make-interval '#(1 6) '#(9 8)))
      (C (make-interval '#(0 0) '#(8 2))))
  (interval= (interval-rebase A '#(1 6)) B)  ;; => #t
  (interval= (interval-rebase A) C))         ;; => #t")

(format-lambda-list '(interval-permute interval permutation))
(<p> "Assumes that "(<code>(<var>'interval))" is an interval and "(<code>(<var>'permutation))" is a permutation with the same dimension as "(<code>(<var>'interval))".  It is an error if the arguments do not satisfy these conditions.")
(<p> "Heuristically, this procedure returns a new interval whose axes have been permuted in a way consistent with "(<code>(<var>'permutation))".
But we have to say how the entries of "(<code>(<var>'permutation))" are associated with the new interval.")
(<p> "We have chosen the following convention: If the permutation is $(\\pi_0,\\ldots,\\pi_{d-1})$, and the argument interval
represents the cross product
$[l_0,u_0)\\times[l_1,u_1)\\times\\cdots\\times[l_{d-1},u_{d-1})$,
then the result represents the cross product
$[l_{\\pi_0},u_{\\pi_0})\\times[l_{\\pi_1},u_{\\pi_1})\\times\\cdots\\times[l_{\\pi_{d-1}},u_{\\pi_{d-1}})$.")
(<p> "For example, if the argument interval represents $[0,4)\\times[0,8)\\times[0,21)\\times [0,16)$ and the
permutation is "(<code>'#(3 0 1 2))", then the result of "(<code> "(interval-permute "(<var>'interval)" "(<var>' permutation)")")" will be
the representation of $[0,16)\\times [0,4)\\times[0,8)\\times[0,21)$.")
        (<p> (<b> "Example: "))(<pre>(<code>"(let ((A (make-interval '#(4 8 21 16)))
      (B (make-interval '#(16 4 8 21))))
  (interval= (interval-permute A '#(3 0 1 2)) B))  ;; => #t"))

(format-lambda-list '(interval-scale interval scales))
(<p> "Assumes that "(<code>(<var>'interval))" is a $d$-dimensional interval $[0,u_1)\\times\\cdots\\times[0,u_{d-1})$ with all lower bounds zero, "
     "and "(<code>(<var>'scales))" is a length-$d$ vector of positive exact integers, which we'll denote by $\\vec s$. Then "(<code>'interval-scale)
     " returns the interval $[0,\\operatorname{ceiling}(u_1/s_1))\\times\\cdots\\times[0,\\operatorname{ceiling}(u_{d-1}/s_{d-1}))$.")
(<p> "It is an error if  "(<code>(<var>'interval))" and "(<code>(<var>'scales))" do not satisfy these conditions.")
(<p> (<b> "Example: "))(<pre>(<code>"(let ((A (make-interval '#(4 7)))
      (B (make-interval '#(2 4))))
  (interval= (interval-scale A '#(3 2)) B))  ;; => #t"))

(format-lambda-list '(interval-cartesian-product  #\. intervals))
(<p> "Assumes that all the arguments are intervals.  Implements the Cartesian product of the intervals in "(<code>(<var>'intervals))". Returns:")
(<pre>(<code>"(make-interval
 (list->vector
  (apply append (map interval-lower-bounds->list intervals)))
 (list->vector
  (apply append (map interval-upper-bounds->list intervals))))"))
(<p> "It is an error if any argument is not an interval.")
(<p> (<b> "Example: "))(<pre>(<code>"(let ((A (make-interval '#(3 4)))
      (B (make-interval '#(1 2 3) '#(7 8 9)))
      (C (make-interval '#(0 0 1 2 3) '#(3 4 7 8 9))))
  (interval= (interval-cartesian-product A B) C))  ;; => #t"))

(<h2> (<a> id: "Storage" "Storage classes"))
(<p> "Conceptually, a storage-class is a set of procedures to manage the backing store of a specialized array.
The procedures allow one to make a backing store, to get values from the store, to set new values, to return the length of the store, to specify a default value for initial elements of the backing store, to recognize which data can be converted to a backing store of this storage class, and to convert data to a backing store of this storage class.  Typically, a backing store is a (heterogeneous or homogeneous) vector.  A storage-class has a type distinct from other Scheme types.")
(<h3> (<a> id: "storageprocedures" "Procedures"))

(format-lambda-list '(make-storage-class getter setter checker maker copier length default data? data->body))
(<p> "Here we assume the following relationships between the arguments of "(<code> 'make-storage-class)".  Assume that the \"elements\" of
the backing store are of some \"type\", either heterogeneous (all Scheme types) or homogeneous (of some restricted type).")
(<ul>
 (<li> (<code> "("(<var>"maker n")" "(<var> 'value)")")" returns a linearly addressed object containing "(<code>(<var> 'n))" elements of value "(<code>(<var> 'value))".")
 (<li> (<var>'copier)" may be #f or a procedure; if a procedure then if "(<code>(<var>'to))" and "(<code>(<var>'from))" were created by "(<code>(<var>'maker))", then "(<code>"("(<var> "copier to at from start end")")")" copies elements from "(<code>(<var>'from))" beginning at "(<code>(<var>'start))" (inclusive) and ending at "(<code>(<var>'end))" (exclusive) to "(<code>(<var>'to))" beginning at "(<code>(<var>'at))".  It is assumed that all the indices involved are within the domain of "(<code>(<var>'from))" and "(<code>(<var>'to))", as needed.  The order in which the elements are copied is unspecified.")
 (<li> "If "(<code>(<var> 'v))" is an object created by "
       (<code>"("(<var> "maker n value")")")
       " and  0 <= "(<code>(<var> 'i))" < "(<code>(<var> 'n))", then "(<code> "("(<var>"getter v i")")")" returns the current value of the "(<code>(<var> 'i))"'th element of "(<code>(<var> 'v))", and "(<code> "("(<var> 'checker)" ("(<var>"getter v i")")) => #t")".")
 (<li> "If "(<code>(<var> 'v))" is an object created by "
       (<code>"("(<var> "maker n value")")")
       ",  0 <= "(<code>(<var> 'i))" < "(<code>(<var> 'n))", and "(<code>"("(<var> 'checker)" "(<var> 'val)") => #t")", then "(<code> "("(<var>"setter v i val")")")" sets the value of the "(<code>(<var> 'i))"'th element of  "(<code>(<var> 'v))" to "(<code>(<var> 'val))".")
 (<li> "If "(<code>(<var> 'v))" is an object created by "
       (<code>"("(<var> "maker n value")")")
       " then "(<code> "("(<var>"length v")")")" returns "(<code>(<var> 'n))".")
 (<li> "The "(<code>(<var>'data?))" and "(<code>(<var>'data->body))" entries are low-level procedures. "(<code>"((storage-class-data? "(<var>'storage-class)") "(<var>'data)")")" returns "(<code>'#t)" if and only if "(<code>"((storage-class-data->body "(<var>'storage-class)") "(<var>'data)")")" returns a body sharing data with "(<code>(<var>'data))", without copying.  See the discussion of "(<code>'make-specialized-array-from-data)"."))
(<p> "If the arguments do not satisfy these conditions, then it is an error to call "(<code> 'make-storage-class)".")
(<p> "Note that we assume that "(<code>(<var> 'getter))" and "(<code>(<var> 'setter))" generally take "(<i> 'O)"(1) time to execute.")

(format-lambda-list '(storage-class? m))
(<p> "Returns "(<code>'#t)" if "(<code>(<var>'m))" is a storage class, and "(<code>'#f)" otherwise.")

(format-lambda-list '(storage-class-getter m))
(format-lambda-list '(storage-class-setter m))
(format-lambda-list '(storage-class-checker m))
(format-lambda-list '(storage-class-maker m))
(format-lambda-list '(storage-class-copier m))
(format-lambda-list '(storage-class-length m))
(format-lambda-list '(storage-class-default m))
(format-lambda-list '(storage-class-data? m))
(format-lambda-list '(storage-class-data->body m) 'storage-class-data-rarrow-body)
(<p> "Assumes that "(<code>(<var> 'm))" is a storage class, created, e.g., by")
(<blockquote>
 (<code>"(make-storage-class "(<var> "getter setter checker maker copier length default data? data->body")")"))
(<p> "Then "
     (<code> 'storage-class-getter)" returns "(<code>(<var> 'getter))", "
     (<code> 'storage-class-setter)" returns "(<code>(<var> 'setter))", "
     (<code> 'storage-class-checker)" returns "(<code>(<var> 'checker))", "
     (<code> 'storage-class-maker)" returns "(<code>(<var> 'maker))", "
     (<code> 'storage-class-copier)" returns "(<code>(<var> 'copier))", "
     (<code> 'storage-class-length)" returns "(<code>(<var> 'length))",  "
     (<code> 'storage-class-default)" returns "(<code>(<var> 'default))", "
     (<code> 'storage-class-data?)" returns "(<code>(<var> 'data?))", and "
     (<code> 'storage-class-data->body)" returns "(<code>(<var> 'data->body))
     ".  Otherwise, it is an error to call any of these procedures.")

(<h3> (<a> id: "storageglobals" "Global variables"))
(format-global-variable 'generic-storage-class)
(format-global-variable 'char-storage-class)
(format-global-variable 's8-storage-class)
(format-global-variable 's16-storage-class)
(format-global-variable 's32-storage-class)
(format-global-variable 's64-storage-class)
(format-global-variable 'u1-storage-class)
(format-global-variable 'u8-storage-class)
(format-global-variable 'u16-storage-class)
(format-global-variable 'u32-storage-class)
(format-global-variable 'u64-storage-class)
(format-global-variable 'f8-storage-class)
(format-global-variable 'f16-storage-class)
(format-global-variable 'f32-storage-class)
(format-global-variable 'f64-storage-class)
(format-global-variable 'c64-storage-class)
(format-global-variable 'c128-storage-class)

(<p> (<code> 'generic-storage-class)" is defined as if by")
(<pre>
 (<code>
"(define generic-storage-class
  (make-storage-class vector-ref
                      vector-set!
                      (lambda (arg) #t)
                      make-vector
                      vector-copy!
                      vector-length
                      0
                      vector?
                      values))"))
(<p> "In the sample implementation "(<code> 'char-storage-class)" is defined as")
(<pre>
 (<code>
"(define char-storage-class
  (make-storage-class string-ref
                      string-set!
                      char?
                      make-string
                      string-copy!
                      string-length
                      #\\0
                      string?
                      values))"))
(<p> "Implementations shall define "(<code> "s"(<var> 'X)"-storage-class")" for "(<code>(<var> 'X))"=8, 16, 32, and 64 (which have default values 0 and
manipulate exact integer values between -2"(<sup>(<var> 'X)"-1")" and
2"(<sup> (<var> 'X)"-1")"-1 inclusive),
 "(<code> "u"(<var> 'X)"-storage-class")" for "(<code>(<var> 'X))"=1, 8, 16, 32, and 64 (which have default values 0 and manipulate exact integer values between 0 and
2"(<sup> (<var> 'X))"-1 inclusive),
"(<code> "f"(<var> 'X)"-storage-class")" for "(<code>(<var> 'X))"= 8, 16, 32, and 64 (which have default value 0.0 and manipulate 8-, 16-, 32-, and 64-bit floating-point numbers), and
"(<code> "c"(<var> 'X)"-storage-class")" for "(<code>(<var> 'X))"= 64 and 128 (which have default value 0.0+0.0i and manipulate complex numbers with, respectively, 32- and 64-bit floating-point numbers as real and imaginary parts).")
(<p> "Implementations with an appropriate homogeneous vector type should define the associated global variable using "(<code>'make-storage-class)".  Otherwise, they shall define the associated global variable to "(<code>'#f)".")

(<h2> (<a> id: "Arrays" "Arrays"))
(<p> "Arrays are a data type distinct from other Scheme data types.")
(<p> "In the examples we use a procedure "(<code>'array-unveil)" that lists the multi-indices and elements of an array in lexicographical order: ")
#;
(define (array-unveil A)
  (let ((D_A (array-domain A))
        (A_  (array-getter A)))
    (interval-for-each (lambda args
                         (for-each (lambda (arg)
                                     (display #\space) (display arg))
                                   args)
                         (for-each display
                                   (list " => " (apply A_ args) #\newline)))
                       D_A)))
(<pre>(<code>"(define (array-unveil A)
  (let ((D_A (array-domain A))
        (A_  (array-getter A)))
    (interval-for-each (lambda args
                         (for-each (lambda (arg)
                                     (display #\\space) (display arg))
                                   args)
                         (for-each display
                                   (list \" => \" (apply A_ args) #\\newline)))
                       D_A)))"))
(<p> "For example:")(<pre>(<code>"(let ((A (make-array (make-interval '#(2 3 2)) list)))
  (array-unveil A))"))
(<p> "displays:")(<pre>(<code>" 0 0 0 => (0 0 0)
 0 0 1 => (0 0 1)
 0 1 0 => (0 1 0)
 0 1 1 => (0 1 1)
 0 2 0 => (0 2 0)
 0 2 1 => (0 2 1)
 1 0 0 => (1 0 0)
 1 0 1 => (1 0 1)
 1 1 0 => (1 1 0)
 1 1 1 => (1 1 1)
 1 2 0 => (1 2 0)
 1 2 1 => (1 2 1)"))

(<h3> (<a> id: "parameters" "Parameters"))

(format-parameter 'specialized-array-default-mutable?)
(<p> "A parameter as specified in "(<a> href: "https://srfi.schemers.org/srfi-39/" "SRFI 39")". Initially, "(<code> "(specialized-array-default-mutable?)")" returns "(<code>'#t)". It is an error to call "(<code> "(specialized-array-default-mutable? "(<var>'arg)")")" if "(<code>(<var>'arg))" is not a boolean.")

(format-parameter 'array-broadcasting?)
(<p> "A parameter as specified in "(<a> href: "https://srfi.schemers.org/srfi-39/" "SRFI 39")". Initially, "(<code> "(array-broadcasting?)")" returns "(<code>'#t)". It is an error to call "(<code> "(array-broadcasting? "(<var>'arg)")")" if "(<code>(<var>'arg))" is not a boolean.")

(<h3> (<a> id: "arrayprocedures" "Procedures"))

(format-lambda-list '(make-array interval getter #\[ setter #\]))
(<p> "Assume first that the optional argument "(<code>'setter)" is not given.")
(<p> "If "(<code>(<var> 'interval))" is an interval and "(<code>(<var> 'getter))" is a procedure from
"(<code>(<var> 'interval))" to Scheme objects, then "(<code> 'make-array)" returns an array with domain "(<code>(<var> 'interval))"
and getter "(<code>(<var> 'getter))".")
(<p> "It is an error to call "(<code> 'make-array)" if "(<code>(<var> 'interval))" and "(<code>(<var> 'getter))"
do not satisfy these conditions.")
(<p> "If now "(<code>(<var> 'setter))" is specified, assume that it is a procedure such that getter and setter satisfy: If")
(<blockquote>
 (<code>"("(<var> 'i)(<sub> '1)",...,"(<var> 'i)(<sub> 'n)")")" $\\neq$ "(<code> "("(<var> 'j)(<sub> '1)",...,"(<var> 'j)(<sub> 'n)")"))
(<p> "are elements of "(<code>(<var> 'interval))" and ")
(<blockquote>
 (<code> "(getter "(<var> 'j)(<sub> '1)" ... "(<var> 'j)(<sub> 'n)") => x"))
(<p> "then \"after\"")
(<blockquote>
 (<code> "(setter v "(<var> 'i)(<sub> '1)" ... "(<var> 'i)(<sub> 'n)")"))
(<p> "we have")
(<blockquote>
 (<code> "(getter "(<var> 'j)(<sub> '1)" ... "(<var> 'j)(<sub> 'n)") => x"))
(<p> "and")
(<blockquote>
 (<code> "(getter "(<var> 'i)(<sub> '1)",...,"(<var> 'i)(<sub> 'n)") => v"))
(<p> "Then "(<code> 'make-array)" builds a mutable array with domain "(<code>(<var> 'interval))", getter "(<code>(<var> 'getter))", and
setter "(<code>(<var> 'setter))".  It is an error to call "(<code> 'make-array)" if its arguments do not satisfy these conditions.")


(<p> (<b> "Example: "))
(<pre>
 (<code>
"  (define a (make-array (make-interval '#(1 1) '#(11 11))
                        (lambda (i j)
                          (if (= i j)
                              1
                              0))))"))
(<p> "defines an array for which "(<code> "(array-getter a)")" returns 1 when i=j and 0 otherwise.")

(<p> (<b> "Example: "))
(<pre>
 (<code>
"(define a   ;; a sparse array
  (let ((domain
         (make-interval '#(1000000 1000000)))
        (sparse-rows
         (make-vector 1000000 '())))
    (make-array
     domain
     (lambda (i j)
       (cond ((assv j (vector-ref sparse-rows i))
              => cdr)
             (else
              0.0)))
     (lambda (v i j)
       (cond ((assv j (vector-ref sparse-rows i))
              => (lambda (pair)
                   (set-cdr! pair v)))
             (else
              (vector-set!
               sparse-rows
               i
               (cons (cons j v)
                     (vector-ref sparse-rows i)))))))))

(define a_ (array-getter a))
(define a! (array-setter a))

(a_ 12345 6789)  => 0.
(a_ 0 0) => 0.
(a! 1.0 0 0) => undefined
(a_ 12345 6789)  => 0.
(a_ 0 0) => 1."))

(<p> (<b> "Example: ")" If an array "(<code>'A)" is empty, e.g., "(<code>"(make-array (make-interval '#(0 0)) getter setter)")", then it is an error to call "(<code>'getter)" or "(<code>'setter)".  Still, such arrays can usefully exist to simplify limit cases of some algorithms.")

(<p> (<b> "Example: ")(<code> "(define a (make-array (make-interval '#()) (lambda () 42)))")" makes an array with a zero-dimensional domain whose getter takes no arguments and always returns 42.")

(<p> (<b> "Example: ")"We can have the following interactive session, which builds a zero-dimensional mutable array: ")(<pre>(<code>
"> (define a
    (let ((contents (box 42)))
      (make-array
       (make-interval '#())
       (lambda ()
         (unbox contents))
       (lambda (val)
         (set-box! contents val)))))
> (define a_ (array-getter a))
> (define a! (array-setter a))
> (a_)
42
> (a! 23)
> (a_)
23"))

(format-lambda-list '(array? object))
(<p> "Returns "(<code> "#t")" if  "(<code>(<var> 'object))" is an array and "(<code> '#f)" otherwise.")

(format-lambda-list '(array-domain array))
(format-lambda-list '(array-getter array))
(<p> "Assumes that "(<code>(<var> 'array))" is an array built, e.g., by")
(<pre>
 (<code> "(make-array "(<var> 'interval)" "(<var> 'getter)" ["(<var> 'setter)"])"))
(<p> "(with or without the optional "(<code>(<var> 'setter))" argument). Then "(<code> 'array-domain)" returns "(<code>(<var> 'interval))
     " and "(<code> 'array-getter)" returns  "(<code>(<var> 'getter))".
It is an error to call "(<code> 'array-domain)" or "(<code> 'array-getter)" if "(<code>(<var> 'array))" is not an array.")
(<p> (<b> "Example: "))
(<pre>
 (<code>
"(define a (make-array (make-interval '#(1 1) '#(11 11))
                      (lambda (i j)
                        (if (= i j)
                            1
                            0))))
(define a_ (array-getter a))

(a_ 3 3) => 1
(a_ 2 3) => 0
(a_ 11 0) => is an error"))

(format-lambda-list '(array-dimension array))
(<p> "Shorthand for "(<code>"(interval-dimension (array-domain "(<var>'array)"))")".  It is an error to call this procedure if "(<code>(<var>'array))" is not an array.")
(<p>(<b> "Example: "))(<pre>(<code>"(let ((A (make-array (make-interval '#(3 3)) list))
      (B (make-array (make-interval '#()) (lambda () 42))))
  (array-dimension A)   ;; => 2
  (array-dimension B))  ;; => 0"))

(format-lambda-list '(mutable-array? object))
(<p> "Returns "(<code>"#t")" if "(<code>(<var> 'object))" is a mutable array and "(<code> '#f)" otherwise.")
(<p>(<b> "Example: "))(<pre>(<code>"(let ((A (array-copy (make-array (make-interval '#(2 2)) list)
                     generic-storage-class
                     #t))
      (B (array-copy (make-array (make-interval '#(2 2)) list)
                     generic-storage-class
                     #f)))
  (mutable-array? A)    ;; => #t
  (mutable-array? B))   ;; => #f"))

(format-lambda-list '(array-setter array))
(<p> "If "(<code>(<var> 'array))" is an array built by")
(<pre>
 (<code> "(make-array "(<var> 'interval)" "(<var> 'getter)" "(<var> 'setter)")"))
(<p> "then "(<code> 'array-setter)" returns "(<code>(<var> 'setter))". Other procedures can build mutable arrays, e.g., "(<code>'array-copy)".  It is an error to call "(<code> 'array-setter)"
if "(<code>(<var> 'array))" is not a mutable array.")

(format-lambda-list '(array-empty? array))
(<p> "Assumes "(<code>(<var>'array))" is an array, and returns "(<code>"(interval-empty? (array-domain "(<var>'array)"))")".  It is an error if the argument is not an array.")
(<p>(<b> "Example: "))(<pre>(<code>"(let ((A (make-array (make-interval '#(2 2)) list))
      (B (make-array (make-interval '#(4 0 4)) list)))
  (array-empty? A)   ;; => #f
  (array-empty? B))  ;; => #t"))


(format-lambda-list '(make-specialized-array interval #\[ storage-class #\[ initial-value #\] #\]))
(<p> "Constructs a mutable specialized array from its arguments.")
(<p> (<code>(<var>'interval))" must be given an interval. If given, "(<code>(<var>'storage-class))" must be a storage class; if it is not given, it defaults to "(<code>'generic-storage-class)". If given, "(<code>(<var>'initial-value))" must be a value that can be manipulated by "(<code>(<var>'storage-class))"; if it is not given, it defaults to "(<code>"(storage-class-default "(<var>'storage-class)")")".")

(<p>"The body of the result is constructed as ")
(<pre>
 (<code>
"  ((storage-class-maker "(<var>'storage-class)")
   (interval-volume "(<var>'interval)")
   "(<var>'initial-value)")"))
(<p> "The indexer of the resulting array is constructed as the lexicographical mapping of "(<code>(<var>'interval))" onto the interval "(<code> "[0,(interval-volume "(<var>'interval)"))")".")

(<p> "After checking that the multi-index argument is valid, "(<code>"(array-getter "(<var>'array)")")" is defined simply as ")
(<pre>
 (<code>
"  (lambda multi-index
    ((storage-class-getter "(<var>'storage-class)")
     (array-body "(<var>'array)")
     (apply (array-indexer "(<var>'array)") multi-index)))"))
(<p> " and "(<code>"(array-setter "(<var>'array)")")" is defined as ")
(<pre>
 (<code>
"  (lambda (val . multi-index)
    ((storage-class-setter "(<var>'storage-class)")
     (array-body "(<var>'array)")
     (apply (array-indexer "(<var>'array)") multi-index)
     val))"
     ))
(<p> "It is an error if the arguments of "(<code>'make-specialized-array)" do not satisfy these conditions.")
(<p> (<b> "Examples: ")" A simple array that can hold any type of element can be defined with "(<code>"(make-specialized-array (make-interval '#(3 3)))")".  If you find that you're using a lot of arrays of unsigned 16-bit integers, one could define ")
(<pre>
 (<code>
"  (define (make-u16-array interval)
    (make-specialized-array interval u16-storage-class 0))"))
(<p> "and then simply call, e.g., "(<code>"(make-u16-array (make-interval '#(3 3)))")".")
(<p>(<b> "Example: "))(<pre>(<code>"(let ((A (make-specialized-array (make-interval '#(2 3)) u8-storage-class 42)))
  (array-unveil A))"))
(<p> "displays:")
(<pre>(<code>" 0 0 => 42
 0 1 => 42
 0 2 => 42
 1 0 => 42
 1 1 => 42
 1 2 => 42"))

(format-lambda-list '(make-specialized-array-from-data data #\[ storage-class  #\[ mutable? #\] #\]))
(<p> "This routine constructs a new specialized array using "(<code>(<var>'data))" as part of the body of the result without copying.")
(<p> "Any missing optional arguments are assigned the values "(<code>'generic-storage-class)" and "(<code>"(specialized-array-default-mutable?)")", respectively.")
(<p> "This routine exploits the low-level representation of the body of a specialized array of a specific storage class, and as such may not be portable between implementations.  Here are several examples.")
(<p> "The sample implementation uses homogeneous vectors to represent the bodies of arrays with storage classes "(<code>'u8-storage-class)", "(<code>'s8-storage-class)", ..., "(<code>'s64-storage-class)", "(<code>'f32-storage-class)", and "(<code>'f64-storage-class)".  Another implementation might use byte-vectors as the bodies of arrays for all these storage classes.")
(<p> "The sample implementation uses homogeneous (f32 and f64) vectors with an even number of elements to represent the bodies of arrays with storage classes "(<code>'c64-storage-class)" and "(<code>'c128-storage-class)". Another implementation with purely inexact complex numbers might make another choice.")
(<p> "Finally, the sample implementation uses "(<code>"(vector "(<var>'n)" (u16vector ...))")" to represent the body of an array with a "(<code>'u1-storage-class)", where "(<code>(<var>'n))" represents the valid number of bits (no more than 16 times the length of the "(<code>'u16vector)").  A Scheme with bitvectors might choose those as the underlying representation of bodies of arrays with "(<code>'u1-storage-class)".")
(<p> "This routine assumes that "(<code>(<var>'mutable?))", if given, is a boolean, and that "(<code>(<var>'storage-class))", if given, is a storage class.  "(<code>(<var>'data))" must be an object for which "(<code>"((storage-class-data? "(<var>'storage-class)") "(<var>'data)")")" returns "(<code>'#t)".")

(<p> "This routine constructs a new one-dimensional array with storage class "(<code>(<var>'storage-class))", mutability "(<code>(<var>'mutable?))", body "(<code>"((storage-class-data->body "(<var>'storage-class)") "(<var>'data)")")", with domain "(<code>"(make-interval (vector "(<var>'N)"))")", where "(<code>(<var>'N))" is the greatest number of elements one can fit into "(<code>(<var>'data))", and indexer "(<code>"(lambda (i) i)")".")
(<p> "It is an error if the arguments do not satisfy these conditions, or if "(<code>(<var>'mutable?))" is true and "(<code>(<var>'data))" is not mutable.")
(<p>(<b> "Example: "))(<pre>(<code>"(let ((A (make-specialized-array-from-data '#(dog cat bird))))
  (array-unveil A))"))
(<p> "displays:")
(<pre>(<code>" 0 => dog
 1 => cat
 2 => bird"))

(<p>(<b>"Discussion:")" Correct transformations on specialized arrays "(<i>'require)" that the array's indexer, which maps the domain of the array to exact integers that index elements of the one-dimensional body of the array, be "(<i>'affine)".  The procedure "(<code>'make-specialized-array-from-data)" provides a structured way to turn externally-provided data into an array with a known, very simple, one-dimensional affine indexer.  With this start, the programmer can apply array transforms (e.g., "(<code>'array-extract)", "(<code>'specialized-array-reshape)", etc.) to massage the data into the shape needed.")
(<p>(<b>"Example: ")"To build a zero-dimensional array that stores its single element in a pre-existing vector, one could use the code:")
(<pre>(<code>
"(pretty-print
 (array->list*
  (specialized-array-reshape           ;; Reshape to zero dimensions
   (make-specialized-array-from-data   ;; The one-dimensional array
    (vector 'foo))
   (make-interval '#()))))"))
(<p> "prints simply")
(<pre>(<code>'foo))

(<p> (<b> "Example: ")"In the sample implementation, if you want to construct a $3\\times3$ array with storage class "(<code>'u1-storage-class)" from a length-one "(<code>'u16vector)" named "(<code>(<var>'board))" then one could write")
(<pre>(<code>
"(let* ((board
        (u16vector #b111100110111))
       (A
        (specialized-array-reshape           ;; Reshape to a 3x3 array
         (array-extract                      ;; Only the first 9 elements
          (make-specialized-array-from-data  ;; A one-dimensional array
           board u1-storage-class)
          (make-interval '#(9)))
         (make-interval '#(3 3))))
       (B                                    ;; An array with same elements
        (list->array (make-interval '#(3 3))
                       '(1 1 1
                         0 1 1
                         0 0 1)
                       u1-storage-class)))
  (define (pad n s)
    (string-append (make-string (- n (string-length s)) #\\0) s))

  (for-each display (list \"(array-every = A B) => \" (array-every = A B) #\\newline))
  (for-each display (list \"(array-body A) => \" (array-body A) #\\newline))
  (for-each display (list \"(array-body B) => \" (array-body B) #\\newline))
  (for-each
   display
   (list \"(pad 16 (number->string (u16vector-ref (vector-ref (array-body A) 1) 0) 2)) => \"
         #\\newline
         (pad 16 (number->string (u16vector-ref (vector-ref (array-body A) 1) 0) 2))
         #\\newline))
  (for-each
   display
   (list \"(pad 16 (number->string (u16vector-ref (vector-ref (array-body B) 1) 0) 2)) => \"
         #\\newline
         (pad 16 (number->string (u16vector-ref (vector-ref (array-body B) 1) 0) 2))
         #\\newline)))"))
(<p> "prints")
(<pre>
"(array-every = A B) => #t
(array-body A) => #(16 #u16(3895))
(array-body B) => #(9 #u16(311))
(pad 16 (number->string (u16vector-ref (vector-ref (array-body A) 1) 0) 2)) =>
0000111100110111
(pad 16 (number->string (u16vector-ref (vector-ref (array-body B) 1) 0) 2)) =>
0000000100110111")
(<p> "The 9 low-order bits of board represent the entries of the array "(<code>'A)", ignoring higher order bits, and you can see the bit order that is used to represent a "(<code>'u1-storage-class-body)".")

(format-lambda-list '(specialized-array? object))
(<p> "Returns "(<code>"#t")" if "(<code>(<var> 'object))" is a specialized-array, and "(<code>"#f")" otherwise. A specialized-array is an array.")

(format-lambda-list '(array-storage-class array))
(format-lambda-list '(array-indexer array))
(format-lambda-list '(array-body array))
(<p> "Assumes that "(<code>(<var>'array))" is a specialized array. "(<code>'array-storage-class)" returns the storage-class of "(<code>(<var> 'array))".")
(<p> (<code>"(array-body "(<var>'array)")")" is a linearly indexed, vector-like object (e.g., a vector, string, u8vector, etc.) indexed from 0.")
(<p> (<code>"(array-indexer "(<var> 'array)")")" is assumed to be a one-to-one, but not necessarily onto,  affine mapping from "(<code> "(array-domain "(<var> 'array)")")" into  the indexing domain of "(<code>"(array-body "(<var> 'array)")")".")
(<p> "Please see "(<a> href: "#make-specialized-array" (<code>'make-specialized-array))" for how "(<code>"(array-body "(<var>'array)")")", etc., are used.")
(<p> "It is an error to call any of these procedures if "(<code>(<var> 'array))" is not a specialized array.")

(format-lambda-list '(array-packed? array))
(<p> "Assumes that "(<code>(<var>'array))" is a specialized array, in which case it returns "(<code>'#t)" if the elements of "(<code>(<var>'array))", taken in lexicographical order, are stored in "(<code>"(array-body "(<var>'array)")")" with increasing and consecutive indices, and "(<code>'#f)" otherwise.")
(<p> "It is an error if "(<code>(<var>'array))" is not a specialized array.")
(<p>(<b> "Example: "))(<pre>(<code>"(let* ((A (make-specialized-array-from-data '#(0 1 2 3)))
       (B (array-reverse A))
       (C (array-sample A '#(2))))
  (array-unveil A)
  (display (array-packed? A)) (newline)
  (array-unveil B)
  (display (array-packed? B)) (newline)  ;; adjacent boxes but decreasing index
  (array-unveil C)
  (display (array-packed? C)) (newline)) ;; non-adjacent boxes"))
(<p> "displays:")
(<pre>(<code>" 0 => 0
 1 => 1
 2 => 2
 3 => 3
#t
 0 => 3
 1 => 2
 2 => 1
 3 => 0
#f
 0 => 0
 1 => 2
#f"))

(format-lambda-list '(specialized-array-share array new-domain new-domain->old-domain))
(<p> "Constructs a new specialized array that shares the body of the specialized array "(<code>(<var> 'array))".
Returns an object that is behaviorally equivalent to a specialized array with the following fields:")
(<pre>
 (<code>
"domain:        new-domain
storage-class: (array-storage-class "(<var> 'array)")
body:          (array-body "(<var> 'array)")
indexer:       (lambda multi-index
                 (call-with-values
                     (lambda ()
                       (apply "(<var>'new-domain->old-domain)"
                              multi-index))
                   (array-indexer "(<var> 'array)")))"))

(<p> "The resulting array inherits its and mutability from "(<code>(<var>'array))".")

(<p> "Because "(<code>(<var>'new-domain->old-domain))" is assumed to be a one-to-one mapping, the volume of "(<code>(<var>'new-domain))" must be no greater than the number of elements of "(<code>(<var>'array))".")

(<p> "Note: It is assumed that the affine structure of the composition of "(<code>(<var> 'new-domain->old-domain))" and "(<code>"(array-indexer "(<var> 'array)")")" will be used to simplify:")
(<pre>
 (<code>
"  (lambda multi-index
    (call-with-values
        (lambda ()
          (apply "(<var>'new-domain->old-domain)" multi-index))
      (array-indexer "(<var> 'array)")))"
      ))
(<p> "It is an error if "(<code>(<var>'array))" is not a specialized array, or if "(<code>(<var>'new-domain))" is not an interval, or if "(<code>(<var>'new-domain->old-domain))" is not a one-to-one affine mapping from "(<code>(<var> 'new-domain))" to
"(<code>"(array-domain "(<var> 'array)")")".")

(<p> (<b> "Example: ")
     "One can apply a \"shearing\" operation to an array as follows: ")
(<pre>
 (<code>
"(define a
  (array-copy
   (make-array (make-interval '#(5 10))
               list)))
(define b
  (specialized-array-share
   a
   (make-interval '#(5 5))
   (lambda (i j)
     (values i (+ i j)))))
;; Print the \"rows\" of b
(array-for-each (lambda (row)
                  (pretty-print (array->list row)))
                (array-curry b 1))

;; which prints
;; ((0 0) (0 1) (0 2) (0 3) (0 4))
;; ((1 1) (1 2) (1 3) (1 4) (1 5))
;; ((2 2) (2 3) (2 4) (2 5) (2 6))
;; ((3 3) (3 4) (3 5) (3 6) (3 7))
;; ((4 4) (4 5) (4 6) (4 7) (4 8))
"
  ))
(<p> "This \"shearing\" operation cannot be achieved by combining the procedures "(<code>'array-extract)", "(<code>'array-translate)", "(<code>'array-permute)", "(<code>'array-translate)", "(<code>'array-curry)", "(<code>'array-reverse)", and "(<code>'array-sample)".")

(format-lambda-list '(array-copy array #\[ storage-class #\[ mutable? #\] #\]))
(format-lambda-list '(array-copy! array #\[ storage-class #\[ mutable? #\] #\]))
(<p> "Assumes that "
     (<code>(<var> 'array))" is an array, "
     (<code>(<var> 'storage-class))" is a storage class that can manipulate all the elements of "(<code>(<var> 'array))", and "
     (<code>(<var> 'mutable?))" is a boolean.")
(<p> "The specialized array returned by "(<code> 'array-copy)" can be defined conceptually by:")
(<pre>
 (<code>
"(list->array (array-domain array)
             (array->list array)
             storage-class
             mutable?)"))
(<p> "If "(<code>(<var>'array))" is a specialized array, then if any of "(<code>(<var>'storage-class))", "(<code>(<var>'mutable?))" are omitted,  their values are assigned "(<code>"(array-storage-class "(<var>'array)")")" and "(<code>"(mutable-array? "(<var>'array)")")", respectively.")
(<p> "Otherwise, omitted arguments are assigned the values "(<code>'generic-storage-class)" and "(<code>"(specialized-array-default-mutable?)")", respectively.")
(<p> "It is an error if the arguments do not satisfy these conditions.")
(<p>(<b> "Example: ")" The "(<a> href: "#PGM" "example of reading PGM files")" exploits the fact that "(<code>'array->list)", and hence "(<code>'array-copy)" and "(<code>'array-copy!)", evaluates an array's getter in lexicographical order.")
(<p>(<b> "Example: "))(<pre>(<code>"(let* ((A (make-array (make-interval '#(2 2)) list))
       (B (array-copy A)))
  (display (specialized-array? A)) (newline)
  (array-unveil A)
  (display (specialized-array? B)) (newline)
  (array-unveil B))"))
(<p>"displays:")
(<pre>(<code>"#f
 0 0 => (0 0)
 0 1 => (0 1)
 1 0 => (1 0)
 1 1 => (1 1)
#t
 0 0 => (0 0)
 0 1 => (0 1)
 1 0 => (1 0)
 1 1 => (1 1)"))


(format-lambda-list '(array-curry array inner-dimension))
(<p> "Assumes that "
     (<code>(<var> 'array))
     " is an array whose domain is an interval  $[l_0,u_0)\\times\\cdots\\times[l_{d-1},u_{d-1})$, and "
     (<code>(<var> 'inner-dimension))
     " is an exact integer between $0$ and $d$ (inclusive). Then "(<code>'array-curry)" returns an immutable array with domain "
     "$[l_0,u_0)\\times\\cdots\\times[l_{d-\\text{inner-dimension}-1},u_{d-\\text{inner-dimension}-1})$"
     ", each of whose entries is in itself an array with domain $[l_{d-\\text{inner-dimension}},u_{d-\\text{inner-dimension}})\\times\\cdots\\times[l_{d-1},u_{d-1})$.")
(<p> "For example, if "(<code>'A)" and "(<code> 'B)" are defined by ")
(<pre>
 (<code>
"(define interval (make-interval '#(10 10 10 10)))
(define A (make-array interval list))
(define B (array-curry A 1))

(define A_ (array-getter A))
(define B_ (array-getter B))"))
(<p> "so")
(<pre>
 (<code>
"(A_ i j k l) => (list i j k l)"))
(<p> "then "(<code>'B)" is an immutable array with domain "(<code>"(make-interval '#(10 10 10))")", each
of whose elements is itself an (immutable) array and ")
(<pre>
 (<code>
"(equal?
 (A_ i j k l)
 ((array-getter (B_ i j k)) l)) => #t"))
(<p> "for all multi-indices "(<code> "i j k l")" in "(<code> 'interval)".")
(<p> "The subarrays are immutable, mutable, or specialized according to whether the array argument is immutable, mutable, or specialized.")
(<p> "More precisely, if ")
(<pre>
 (<code> "0 <= "(<var> 'inner-dimension)" <= (array-dimension "(<var> 'array)")"))
(<p> "then "(<code> 'array-curry)" returns a result as follows.")
(<p> "If the input array is specialized, then array-curry returns")
(<pre>
 (<code>
"(call-with-values
    (lambda () (interval-projections (array-domain "(<var> 'array)")
                                     "(<var> 'inner-dimension)"))
  (lambda (outer-interval inner-interval)
    (make-array
     outer-interval
     (lambda outer-multi-index
       (specialized-array-share
        "(<var> 'array)"
        inner-interval
        (lambda inner-multi-index
          (apply values
                 (append outer-multi-index
                         inner-multi-index))))))))"))

(<p> "Otherwise, if the input array is mutable, then array-curry returns")
(<pre>
 (<code>
"(call-with-values
    (lambda () (interval-projections (array-domain "(<var> 'array)")
                                     "(<var> 'inner-dimension)"))
  (lambda (outer-interval inner-interval)
    (make-array
     outer-interval
     (lambda outer-multi-index
       (make-array
        inner-interval
        (lambda inner-multi-index
          (apply (array-getter "(<var> 'array)")
                 (append outer-multi-index
                         inner-multi-index)))
        (lambda (v . inner-multi-index)
          (apply (array-setter "(<var> 'array)")
                 v
                 (append outer-multi-index
                         inner-multi-index))))))))"))
(<p> "Otherwise, array-curry returns")
(<pre>
 (<code>
"(call-with-values
    (lambda () (interval-projections (array-domain "(<var> 'array)")
                                     "(<var> 'inner-dimension)"))
  (lambda (outer-interval inner-interval)
    (make-array
     outer-interval
     (lambda outer-multi-index
       (make-array
        inner-interval
        (lambda inner-multi-index
          (apply (array-getter "(<var> 'array)")
                 (append outer-multi-index
                         inner-multi-index))))))))"))
(<p> "It is an error to call "(<code> 'array-curry)" if its arguments do not satisfy these conditions.")
(<p> "If "(<code>(<var>'array))" is a specialized array, the subarrays of the result inherit their mutability from "(<code>(<var>'array))".")
(<p> (<b> "Note: ")"Let's denote by "(<code>(<var>'B))" the result of "(<code>"(array-curry "(<var>'A)" "(<var>'k)")")". While the result of calling "(<code>"(array-getter "(<var>'B)")")
     " is an immutable, mutable, or specialized array according to whether "(<code>(<var>'A))" itself is immutable, mutable, or specialized, "(<code>(<var>'B))" is always an immutable array, where "(<code>"(array-getter "(<var>'B)")")", which returns an array, is computed anew for each call.  If "(<code>"(array-getter "(<var>'B)")")" will be called multiple times with the same arguments, it may be useful to store these results in a specialized array for fast repeated access.")
(<p> "Please see the note in the discussion of "(<a> href: "#array-tile" "array-tile")".")

(<p>(<b>"Example:"))
(<pre>(<code>"(let* ((A (make-array (make-interval '#(10 10)) list))
       (B (array-curry A 1)))
  (array-ref A 3 4)               ;; => (3 4)
  (array-ref (array-ref B 3) 4))  ;; => (3 4)"))

(<p> (<b> "Example: ")"NumPy has the operation "(<a> href: "https://numpy.org/doc/stable/reference/generated/numpy.squeeze.html" "numpy.squeeze")", which can eliminate, or \"squeeze\" out, all axes of an array with length 1.  It can be implemented using "(<code>'partition)" from SRFI 1 by")
(<pre>(<code>"(define (array-squeeze a)
  (call-with-values
      (lambda ()
        (let ((interval (array-domain a)))
          (partition (lambda (k)
                       (eqv? (interval-width interval k) 1))
                     (iota (array-dimension a)))))
    (lambda (ones rest)
      (car (array->list
            (array-curry      ;; this array has exactly one element
             (array-permute   ;; put all length-one axes at beginning
              a (list->vector (append ones rest)))
             (length rest)))))))

(array->list* (array-squeeze (make-array (make-interval '#(1 2 1 2)) list)))
=>
(((0 0 0 0)
  (0 0 0 1))
 ((0 1 0 0)
  (0 1 0 1)))

(array->list*
 (array-squeeze
  (make-array (make-interval '#(1 2 3 4) '#(2 3 4 5))
              (lambda args (apply string-append (map number->string args))))))
=>
\"1234\"
(array-dimension
 (array-squeeze
  (make-array (make-interval '#(1 2 3 4) '#(2 3 4 5))
              (lambda args
                (apply string-append (map number->string args))))))
=>
0

(array->list*
 (array-squeeze
  (make-array (make-interval '#(1 2 3 4) '#(3 3 4 5))
              (lambda args
                (apply string-append (map number->string args))))))
=>
(\"1234\" \"2234\")
(array-dimension
 (array-squeeze
  (make-array (make-interval '#(1 2 3 4) '#(3 3 4 5))
              (lambda args
                (apply string-append (map number->string args))))))
=>
1"))

(format-lambda-list '(array-extract array interval))
(<p> "Returns a new array with the same getter (and setter, if appropriate) of the first argument, defined on the second argument.")
(<p> "Assumes that "(<code>(<var> 'array))" is an array and "(<code>(<var> 'interval))" is an interval that is a sub-interval of "(<code> "(array-domain "(<var> 'array)")")".  If "(<code>(<var>'array))" is a specialized array, then returns ")
(<pre>
 (<code>
"  (specialized-array-share "(<var> 'array)"
                           "(<var> 'interval)"
                           values)
  "))
(<p> "Otherwise, if "(<code>(<var>'array))" is a mutable array, then "(<code> 'array-extract)" returns ")
(<pre>
 (<code>
"  (make-array "(<var> 'interval)"
              (array-getter "(<var> 'array)")
              (array-setter "(<var> 'array)"))

" ))
(<p> "Finally, if "(<code>(<var>'array))" is an immutable array, then "(<code> 'array-extract)" returns ")
(<pre>
 (<code>
"  (make-array "(<var> 'interval)"
              (array-getter "(<var> 'array)"))
"
              ))
(<p> "It is an error if the arguments of "(<code>'array-extract)" do not satisfy these conditions.")
(<p> "If "(<code>(<var>'array))" is a specialized array, the resulting array inherits its mutability from "(<code>(<var>'array))".")
(<p>(<b> "Example: "))(<pre>(<code>"(let* ((A (make-array (make-interval '#(3 3)) list))
       (B (array-extract A (make-interval '#(1 0) '#(3 2)))))
  (display \"A:\\n\")
  (array-unveil A)
  (display \"B:\\n\")
  (array-unveil B))"))
(<p>"displays:")(<pre>(<code>"A:
 0 0 => (0 0)
 0 1 => (0 1)
 0 2 => (0 2)
 1 0 => (1 0)
 1 1 => (1 1)
 1 2 => (1 2)
 2 0 => (2 0)
 2 1 => (2 1)
 2 2 => (2 2)
B:
 1 0 => (1 0)
 1 1 => (1 1)
 2 0 => (2 0)
 2 1 => (2 1)"))

(format-lambda-list '(array-tile array S))
(<p> "Decomposes  the array "(<code>(<var>'array))" into subarrays, or "(<i>'tiles)", specified by "(<i>'cuts)" perpendicular to the coordinate axes of "(<code>(<var>'array))", which are specified by the elements second argument, "(<code>(<var>'S))", and returns an array $T$ whose elements are those tiles.")
(<p> "If the $k$th axis of "(<code>(<var>'array))" has zero width, then the $k$th component of "(<code>(<var>'array))" must be a nonempty vector of exact zeros.")
(<p> "Otherwise, if the $k$th component of "(<code>(<var>'S))" is a positive exact integer $s$, then the cuts perpendicular to the $k$th coordinate axis are evenly spaced, beginning at the lower bound in the $k$th axis, $l_k$, cutting "(<code>(<var>'array))" into slices of uniform width, except possibly for the last slice.  If the $k$ component of "(<code>(<var>'S))" is a vector $C$ of nonnegative exact integers that sum to "(<code>"(interval-width (array-domain "(<var>'array)") k)")", then the cuts in the $k$th direction create slices with widths $C_0, C_1, \\ldots$, beginning at the lower bound $l_k$. These subarrays completely \"tile\" "(<code>(<var>'array))", in the sense that every entry in "(<code>(<var>'array))" is an entry of precisely one entry of the result $T$.")

(<p> "More formally, assume the domain of "(<code>(<var>'array))" is the interval $[l_0,u_0)\\times\\cdots\\times [l_{d-1},u_{d-1})$; $T$ is an immutable array with all lower bounds zero.  We specify the lower and upper bounds of the array comprising each element of $T$ that is extracted from "(<code>(<var>'array))" in the sense of "(<code>'array-extract)",  as follows.")
(<p> "If the $k$th component of "(<code>(<var>'S))" is an exact positive integer $s$, then the elements of $T$ with $k$th coordinates $j_k$ are subarrays of "(<code>(<var>'array))" with $k$th lower and upper bounds given by $l_k+j_k\\times s$ and $\\min(l_k+(j_k+1)s, u_k)$, respectively. (The \"minimum\" operator is necessary if $u_k-l_k$ is not divisible by $s$.)")
(<p> "If, on the other hand, the $k$ component of "(<code>(<var>'S))" is a vector of nonnegative exact integers $C$ whose components sum to $u_k-l_k$, then the elements of $T$ with $k$th coordinates $j_k$ are subarrays of "(<code>(<var>'array))" with $k$th lower and upper bounds given by
$$
l_k+\\sum_{i<j_k} C_i\\quad\\text{ and }\\quad l_k+\\sum_{i\\leq j_k} C_i,\\quad\\text{respectively.}
$$
")
(<p> "It is an error if the arguments of "(<code>'array-tile)" do not satisfy these conditions.")
(<p> "If "(<code>(<var>'array))" is a specialized array, the subarrays of the result inherit their mutability from "(<code>(<var>'array))".")

(<p>(<b>"Example: "))
(<pre>(<code>"(define T
  (list*->array
   2
   '(( 1  2  3  4  5  6)
     ( 7  8  9 10 11 12)
     (13 14 15 16 17 18)
     (19 20 21 22 23 24)
     (25 26 27 28 29 30)
     (31 32 33 34 35 36))))
(array->list*
 (array-map array->list*
            (array-tile T '#(#(3 1 2)
                             3))))
=>
((((1 2 3)                     ;; upper left corner
   (7 8 9)
   (13 14 15))
  ((4 5 6)                     ;; upper right corner
   (10 11 12)
   (16 17 18)))
 (((19 20 21))                 ;; left middle row
  ((22 23 24)))                ;; right middle row
 (((25 26 27)                  ;; lower left corner
   (31 32 33))
  ((28 29 30)                  ;; lower right corner
   (34 35 36))))"))


(<p> (<b> "Note: ")"The procedures "(<code>'array-tile)" and "(<code>'array-curry)" both decompose an array into subarrays, but in different ways.  For example, if "(<code>(<var>'A))" is defined as "(<code>"(make-array (make-interval '#(10 10)) list)")", then "(<code>"(array-tile "(<var>'A)" '#(1 10))")" returns an array with domain "(<code>"(make-interval '#(10 1))")" for which the value at the multi-index "(<code>"("(<var>'i)" 0)")" is an array with domain "(<code>"(make-interval (vector "(<var>'i)" 0) (vector (+ "(<var>'i)" 1) 10))")" (i.e., a two-dimensional array whose elements are two-dimensional arrays), while "(<code>"(array-curry "(<var>'A)" 1)")" returns an array with domain "(<code>"(make-interval '#(10))")", each element of which has domain "(<code>"(make-interval '#(10))")" (i.e., a one-dimensional array whose elements are one-dimensional arrays).")


(format-lambda-list '(array-translate array translation))
(<p> "Assumes that "(<code>(<var>'array))" is an array, "(<code>(<var>'translation))" is a translation, and that the dimensions of the array and the translation are the same. The resulting array will have domain "(<code>"(interval-translate (array-domain array) translation)")".")
(<p> "If "(<code>(<var>'array))" is a specialized array, returns a new specialized array")
(<pre>
 (<code>
"(specialized-array-share
 "(<var>'array)"
 (interval-translate (array-domain "(<var>'array)")
                     "(<var>'translation)")
 (lambda multi-index
   (apply values
          (map -
               multi-index
               (vector->list "(<var>'translation)")))))"))
(<p> "that shares the body of "(<code>(<var>'array))", as well as inheriting its mutability.")
(<p> "If "(<code>(<var>'array))" is not a specialized array but is a mutable array, returns a new mutable array")
(<pre>
 (<code>
"(make-array
 (interval-translate (array-domain "(<var>'array)")
                     "(<var>'translation)")
 (lambda multi-index
   (apply (array-getter "(<var>'array)")
          (map -
               multi-index
               (vector->list "(<var>'translation)"))))
 (lambda (val . multi-index)
   (apply (array-setter "(<var>'array)")
          val
          (map -
               multi-index
               (vector->list "(<var>'translation)")))))
 "))
(<p> "that employs the same getter and setter as the original array argument.")
(<p> "If "(<code>(<var>'array))" is not a mutable array, returns a new array")
(<pre>
 (<code>
"(make-array
 (interval-translate (array-domain "(<var>'array)")
                     "(<var>'translation)")
 (lambda multi-index
   (apply (array-getter "(<var>'array)")
          (map - multi-index (vector->list "(<var>'translation)")))))"))
(<p> "that employs the same getter as the original array.")
(<p> "It is an error if the arguments do not satisfy these conditions.")
(<p>(<b> "Example: "))(<pre>(<code>"(let* ((A (make-array (make-interval '#(2 3)) list))
       (B (array-translate A '#(1 -3))))
  (display \"A:\\n\")
  (array-unveil A)
  (interval= (array-domain B) (make-interval '#(1 -3) '#(3 0))) ;; => #t
  (display \"B:\\n\")
  (array-unveil B))"))
(<p>"displays:")
(<pre>(<code>"A:
 0 0 => (0 0)
 0 1 => (0 1)
 0 2 => (0 2)
 1 0 => (1 0)
 1 1 => (1 1)
 1 2 => (1 2)
B:
 1 -3 => (0 0)
 1 -2 => (0 1)
 1 -1 => (0 2)
 2 -3 => (1 0)
 2 -2 => (1 1)
 2 -1 => (1 2)"))

(format-lambda-list '(array-rebase array #\[ lower-bounds #\]))
(<p> "Assumes that "(<code>(<var>'array))" is an array and "(<code>(<var>'lower-bounds))", if given, is a vector of exact integers, and that the dimension of the array and the length of the vector are the same. If "(<code>(<var>'lower-bounds))" is not given, it is assumed to have all zero components.  It is an error if "(<code>(<var>'array))" and "(<code>(<var>'lower-bounds))" do not satisfy these conditions.")
(<p> (<code>'array-rebase)" returns"
(<pre>"(let ((translation
       (vector-map -
                   lower-bounds
                   (interval-lower-bounds->vector
                    (array-domain array)))))
  (array-translate array translation))"))
(<p> "It is an error if the arguments do not satisfy these conditions.")

(<p>(<b> "Example: "))(<pre>(<code>"(let* ((A (make-array (make-interval '#(1 1) '#(2 3)) list))
       (B (array-rebase A '#(4 3)))
       (C (array-rebase A)))
  (display \"A:\\n\")
  (array-unveil A)
  (display \"B:\\n\")
  (array-unveil B)
  (display \"C:\\n\")
  (array-unveil C))"))
(<p>"displays:")
(<pre>(<code>"A:
 1 1 => (1 1)
 1 2 => (1 2)
B:
 4 3 => (1 1)
 4 4 => (1 2)
C:
 0 0 => (1 1)
 0 1 => (1 2)"))

(format-lambda-list '(array-permute array permutation))
(<p> "Assumes that "(<code>(<var>'array))" is an array and "(<code>(<var>'permutation))" is a permutation, and that the dimensions of the array and the permutation are the same. The resulting array will have domain "(<code>"(interval-permute (array-domain array) permutation)")".")
(<p> "We begin with an example.  Assume that the domain of "(<code>(<var>'array))" is represented by the interval  $[0,4)\\times[0,8)\\times[0,21)\\times [0,16)$, as in the example for "(<code>'interval-permute)", and the permutation is "(<code>'#(3 0 1 2))".  Then the domain of the new array is the interval $[0,16)\\times [0,4)\\times[0,8)\\times[0,21)$.")
(<p> "So the multi-index argument of the "(<code>'getter)" of the result of "(<code>'array-permute)" must lie in the new domain of the array, the interval  $[0,16)\\times [0,4)\\times[0,8)\\times[0,21)$.  So if we define "(<code>(<var>'old-getter))" as "(<code>"(array-getter "(<var>'array)")")", the definition of the new array must be in fact")
(<pre>
 (<code>
"(make-array (interval-permute (array-domain "(<var>'array)")
                              '#(3 0 1 2))
            (lambda (l i j k)
              (old-getter i j k l)))
" ))
(<p> "So you see that if the first argument if the new getter is in $[0,16)$, then indeed the fourth argument of "(<code>(<var>'old-getter))" is also in $[0,16)$, as it should be. This is a subtlety that I don't see how to overcome.  It is the listing of the arguments of the new getter, the "(<code>'lambda)", that must be permuted.")

(<p> "Mathematically, we can define $\\pi^{-1}$, the inverse of a permutation $\\pi$, such that $\\pi^{-1}$ composed with $\\pi$ gives the identity permutation.  Then the getter of the new array is, in pseudo-code, "(<code>"(lambda multi-index (apply "(<var>'old-getter)" (")"$\\pi^{-1}$"(<code>" multi-index)))")".  We have assumed that $\\pi^{-1}$ takes a list as an argument and returns a list as a result.")


(<p> "Employing this same pseudo-code, if "(<code>(<var>'array))" is a specialized array and we denote the permutation by $\\pi$, then "(<code>'array-permute)" returns the new specialized array")
(<pre>(<code>
"(specialized-array-share "(<var>'array)"
                         (interval-permute (array-domain "(<var>'array)") "(<unprotected>"&pi;")")
                         (lambda multi-index
                           (apply values ("(<unprotected> "&pi;")(<sup>"-1")" multi-index))))"))
(<p> "The resulting array shares the body of "(<code>(<var>'array))", as well as its  mutability.")


(<p> "Again employing this same pseudo-code, if "(<code>(<var>'array))" is not a specialized array, but is
a mutable array, then "(<code>'array-permute)" returns the new mutable array")
(<pre>(<code>
"(make-array (interval-permute (array-domain "(<var>'array)") "(<unprotected>"&pi;")")
            (lambda multi-index
              (apply (array-getter "(<var>'array)")
                     ("(<unprotected> "&pi;")(<sup>"-1")" multi-index)))
            (lambda (val . multi-index)
              (apply (array-setter "(<var>'array)")
                     val
                     ("(<unprotected> "&pi;")(<sup>"-1")" multi-index))))"))
(<p> "which employs the setter and the getter of the argument to "(<code>'array-permute)".")

(<p> "Finally, if "(<code>(<var>'array))" is not a mutable array, then "(<code>'array-permute)" returns")
(<pre>(<code>
"(make-array (interval-permute (array-domain "(<var>'array)") "(<unprotected>"&pi;")")
            (lambda multi-index
              (apply (array-getter "(<var>'array)")
                     ("(<unprotected> "&pi;")(<sup>"-1")" multi-index))))"))
(<p> "The only length-zero permutation is the empty permutation, specified by "(<code>"'#()")".")
(<p>"It is an error to call "(<code>'array-permute)" if its arguments do not satisfy these conditions.")
(<p>(<b> "Example: "))(<pre>(<code>"(let* ((A (make-array (make-interval '#(1 3 2)) list))
       (B (array-permute A '#(2 1 0))))
  (display \"A:\\n\")
  (array-unveil A)
  (interval= (array-domain B) (make-interval '#(2 3 1))) ;; => #t
  (display \"B:\\n\")
  (array-unveil B))"))
(<p>"displays:")
(<pre>(<code>"A:
 0 0 0 => (0 0 0)
 0 0 1 => (0 0 1)
 0 1 0 => (0 1 0)
 0 1 1 => (0 1 1)
 0 2 0 => (0 2 0)
 0 2 1 => (0 2 1)
B:
 0 0 0 => (0 0 0)
 0 1 0 => (0 1 0)
 0 2 0 => (0 2 0)
 1 0 0 => (0 0 1)
 1 1 0 => (0 1 1)
 1 2 0 => (0 2 1)"))


(format-lambda-list '(array-reverse array #!optional flip?))
(<p> "We assume that "(<code>(<var>'array))" is an array and "(<code>(<var>'flip?))", if given, is a vector of booleans whose length is the same as the dimension of "(<code>(<var>'array))".  If "(<code>(<var>'flip?))" is not given, it is set to a vector with length the same as the dimension of "(<code>(<var>'array))", all of whose elements are "(<code> "#t")".")
(<p> (<code>'array-reverse)" returns a new array  that is specialized,  mutable, or immutable according to whether "(<code>(<var>'array))" is specialized, mutable, or immutable, respectively.  Informally, if "(<code>"(vector-ref "(<var>'flip?)" k)")" is true, then the ordering of multi-indices in the k'th coordinate direction is reversed, and is left undisturbed otherwise.")
(<p> "More formally, we introduce the procedure ")
(<pre>
 (<code>
"(define flip-multi-index
  (let* ((domain (array-domain "(<code>(<var>'array))"))
         (lowers (interval-lower-bounds->list domain))
         (uppers (interval-upper-bounds->list domain)))
    (lambda (multi-index)
      (map (lambda (i_k flip?_k l_k u_k)
             (if flip?_k
                 (- (+ l_k u_k -1) i_k)
                 i_k))
           multi-index
           (vector->list "(<var>'flip?)")
           lowers
           uppers))))"))
(<p> "Then if "(<code>(<var>'array))" is specialized, "(<code>'array-reverse)" returns ")
(<pre>
 (<code>
"(specialized-array-share
 "(<code>(<var>'array))"
 domain
 (lambda multi-index
   (apply values
          (flip-multi-index multi-index))))"))
(<p> "and the result inherits the mutability of "(<code>(<var>'array))".")
(<p> "Otherwise, if "(<code>(<var>'array))" is mutable, then "(<code>'array-reverse)" returns")
(<pre>
 (<code>
"(make-array
 domain
 (lambda multi-index
   (apply (array-getter "(<code>(<var>'array))")
          (flip-multi-index multi-index)))
   (lambda (v . multi-index)
     (apply (array-setter "(<code>(<var>'array))")
            v
            (flip-multi-index multi-index)))))"))
(<p> "Finally, if "(<code>(<var>'array))" is immutable, then "(<code>'array-reverse)" returns ")
(<pre>
 (<code>
"(make-array
 domain
 (lambda multi-index
   (apply (array-getter "(<code>(<var>'array))")
          (flip-multi-index multi-index))))) "))
(<p> "It is an error if "(<code>(<var>'array))" and "(<code>(<var>'flip?))" don't satisfy these requirements.")
(<p> (<b> "Example: ")"The following example was motivated by "(<a> href: "https://funcall.blogspot.com/2020/01/palindromes-redux-and-sufficiently.html" "a blog post by Joe Marshall")".")
(<pre>
 (<code>"(define (palindrome? s)
  ;; Is the string s a palindrome, ignoring case
  (let ((S (make-specialized-array-from-data s char-storage-class))
        (half-domain (make-interval (vector (quotient (string-length s) 2)))))
    ;; The two extracted arrays are empty if s consists of 0 or 1 characters
    (array-every char-ci=?
                 ;; the first half of S
                 (array-extract S half-domain)
                 ;; the reversed second half of S
                 (array-extract (array-reverse S) half-domain))))

(for-each (lambda (s)
            (for-each display
                      (list \"(palindrome? \\\"\"
                            s
                            \"\\\") => \"
                            (palindrome? s)
                            #\\newline)))
          '(\"\" \"a\" \"aa\" \"ab\" \"aba\" \"abc\" \"abba\" \"abca\" \"abbc\" \"AManAPlanACanalPanama\"))

(palindrome? \"\") => #t
(palindrome? \"a\") => #t
(palindrome? \"aa\") => #t
(palindrome? \"ab\") => #f
(palindrome? \"aba\") => #t
(palindrome? \"abc\") => #f
(palindrome? \"abba\") => #t
(palindrome? \"abca\") => #f
(palindrome? \"abbc\") => #f
(palindrome? \"AManAPlanACanalPanama\") => #t
"))


(format-lambda-list '(array-sample array scales))
(<p> "Assumes that "(<code>(<var>'array))" is an array all of whose lower bounds are zero, "
     "and "(<code>(<var>'scales))" is a vector of positive exact integers whose length is the same as the dimension of "(<code>(<var>'array))".")
(<p>"Informally, if we construct a new matrix $S$ with the entries of "(<code>(<var>'scales))" on the main diagonal, then "
     "the $\\vec i$th element of "(<code>"(array-sample "(<var>'array)" "(<var>'scales)")")" is the $S\\vec i$th element of "(<code>(<var>'array))".")
(<p> "More formally, if "(<code>(<var>'array))" is specialized, then "(<code>'array-sample)" returns ")
(<pre>
 (<code>
"(specialized-array-share
 "(<code>(<var>'array))"
 (interval-scale (array-domain "(<code>(<var>'array))")
                 "(<code>(<var>'scales))")
 (lambda multi-index
   (apply values
          (map * multi-index (vector->list "(<code>(<var>'scales))")))))"))
(<p> "with the result inheriting the mutability of "(<code>(<var>'array))".")
(<p> "Otherwise, if "(<code>(<var>'array))" is mutable, then "(<code>'array-sample)" returns")
(<pre>
 (<code>
"(make-array
 (interval-scale (array-domain "(<code>(<var>'array))")
                 "(<code>(<var>'scales))")
 (lambda multi-index
   (apply (array-getter "(<code>(<var>'array))")
          (map * multi-index (vector->list "(<code>(<var>'scales))"))))
 (lambda (v . multi-index)
   (apply (array-setter "(<code>(<var>'array))")
          v
          (map * multi-index (vector->list "(<code>(<var>'scales))")))))"))
(<p> "Finally, if "(<code>(<var>'array))" is immutable, then "(<code>'array-sample)" returns ")
(<pre>
 (<code>
"(make-array
 (interval-scale (array-domain "(<code>(<var>'array))")
                 "(<code>(<var>'scales))")
 (lambda multi-index
   (apply (array-getter "(<code>(<var>'array))")
          (map * multi-index (vector->list "(<code>(<var>'scales))")))))"))
(<p> "It is an error if "(<code>(<var>'array))" and "(<code>(<var>'scales))" don't satisfy these requirements.")
(<p>(<b> "Example: "))(<pre>(<code>"(let* ((A (make-array (make-interval '#(3 2)) list))
       (B (array-sample A '#(2 1))))
  (interval= (array-domain B) (make-interval '#(2 2)))  ;; => #t
  (display \"A:\\n\")
  (array-unveil A)
  (display \"B:\\n\")
  (array-unveil B))"))
(<p> "displays:")
(<pre>(<code>"A:
 0 0 => (0 0)
 0 1 => (0 1)
 1 0 => (1 0)
 1 1 => (1 1)
 2 0 => (2 0)
 2 1 => (2 1)
B:
 0 0 => (0 0)
 0 1 => (0 1)
 1 0 => (2 0)
 1 1 => (2 1)"))

(format-lambda-list '(array-insert-axis A k #\[ u_k #\]))
(<p> "Assumes that "(<code>(<var>'A))" is an array, "(<code>(<var>'k))" is an exact integer between 0 and "(<code>"(array-dimension A)")", inclusive, and "(<code>(<var>'u_k))", if given, is a positive exact integer; if "(<code>(<var>'u_k))" is not given it is assumed to be 1.")
(<p> "Let us define the following procedure: ")
(<pre>(<code>"(define (process-args args)
  (append (take args k) (drop args (+ k 1))))"))
(<p>"If "(<code>(<var>'A))" is specialized, then "(<code>'array-insert-axis)" returns the array:")
(<p>(<pre>(<code>"(specialized-array-share A
                         (interval-insert-axis A k u_k)
                         (lambda args (apply values (process-args args))))")))
(<p>"Note, however, that if "(<cv>'u_k)" is greater than 1, then the resulting array is immutable, even if "(<cv>'A)" itself is mutable.")
(<p> "If "(<cv>'A)" is not specialized, we require that "(<cv>'u_k)", if given, have the value 1, and:")
(<p> "If "(<code>(<var>'A))" is mutable, the procedure returns:")
(<pre>(<code>"(make-array (interval-insert-axis A k u_k)
            (lambda args (apply (array-getter A) (process-args args)))
            (lambda (v . args) (apply (array-setter A) v (process-args args))))"))
(<p> "and otherwise, the procedure returns:")
(<pre>(<code>"(make-array (interval-insert-axis A k u_k)
            (lambda args (apply (array-getter A) (process-args args)))"))
(<p> "It is an error if the arguments do not satisfy these assumptions")
(<p> (<b> "Note: ")"The procedure "(<code>'process-args)" defines an affine transform on its arguments, but because it drops the "(<code>(<var>'k))"th argument, the transform is not one-to-one when "(<code>(<var>'u_k))" is greater than one.")
(<p>(<b>"Example: "))
(<pre>(<code>"(let ((A (list->array (make-interval '#(2 3)) (iota 6))))
  (display \"A:\") (newline)
  (array-unveil A)
  (display \"insert axis 0:\") (newline)
  (array-unveil (array-insert-axis A 0 2))
  (display \"insert axis 1:\") (newline)
  (array-unveil (array-insert-axis A 1 2))
  (display \"insert axis 2:\") (newline)
  (array-unveil (array-insert-axis A 2 2)))"))
(<p>"displays: ")
(<pre>(<code>"A:
 0 0 => 0
 0 1 => 1
 0 2 => 2
 1 0 => 3
 1 1 => 4
 1 2 => 5
insert axis 0:
 0 0 0 => 0
 0 0 1 => 1
 0 0 2 => 2
 0 1 0 => 3
 0 1 1 => 4
 0 1 2 => 5
 1 0 0 => 0
 1 0 1 => 1
 1 0 2 => 2
 1 1 0 => 3
 1 1 1 => 4
 1 1 2 => 5
insert axis 1:
 0 0 0 => 0
 0 0 1 => 1
 0 0 2 => 2
 0 1 0 => 0
 0 1 1 => 1
 0 1 2 => 2
 1 0 0 => 3
 1 0 1 => 4
 1 0 2 => 5
 1 1 0 => 3
 1 1 1 => 4
 1 1 2 => 5
insert axis 2:
 0 0 0 => 0
 0 0 1 => 0
 0 1 0 => 1
 0 1 1 => 1
 0 2 0 => 2
 0 2 1 => 2
 1 0 0 => 3
 1 0 1 => 3
 1 1 0 => 4
 1 1 1 => 4
 1 2 0 => 5
 1 2 1 => 5"))

(format-lambda-list '(array-broadcast array new-domain))
(<p> "Assumes that "(<cv>'array)" is an array and "(<cv>'new-domain)" is an interval for which "(<code>"(compute-broadcast-interval (array-domain "(<var>'array)") "(<var>'new-domain)")")" returns "(<cv>'new-domain)" itself.")
(<p> "If "(<cv>'array)" is a generalized array, then it is assumed that "(<code>"(interval-volume (array-domain "(<var>'array)"))")
     " is the same as "(<code>"(interval-volume "(<var>'new-domain)")")".  This necessarily means that "(<var>'new-domain)
     " can be derived from "(<code>"(array-domain "(<var>'array)")")" solely by adding axes with lower bound 0 and upper bound 1 to the left of "
     (<code>"(array-domain "(<var>'array)")")"; let's assume that "(<code>'k)" such axes have been added.")
(<p> "Then if "(<cv>'array)" is a mutable generalized array, "(<code>'array-broadcast)" returns")
(<pre>(<code>"(make-array new-domain
            (lambda args
              (apply (array-getter array) (drop args k)))
            (lambda (v . args)
              (apply (array-setter array) v (drop args k))))"))
(<p> "and if "(<cv>'array)" is an immutable generalized array, then  "(<code>'array-broadcast)" returns")
(<pre>(<code>"(make-array new-domain
            (lambda args
              (apply (array-getter array) (drop args k))))"))
(<p> "If "(<cv>'array)" is a specialized array, then we define the following procedure:")
(<pre>(<code>"(define process-args
  (let* ((new-dim
          (interval-dimension new-domain))
         (old-dim
          (array-dimension array))
         (left-axes-to-trim
          (- new-dim old-dim))
         (old-uppers
          (interval-upper-bounds->list (array-domain array)))
         (trimmed-new-uppers
          (drop (interval-upper-bounds->list new-domain)
                left-axes-to-trim)))
    (lambda args
      ;; We broadcast along the left axes we trim
      (let ((trimmed-args (drop args left-axes-to-trim)))
        (apply values
               (map (lambda (index old-upper new-upper)
                      (if (= old-upper new-upper)
                          ;; array is not broadcast along this axis
                          index
                          ;; array is broadcast along this axis
                          0))
                    trimmed-args old-uppers trimmed-new-uppers))))))"))
(<p> "Then "(<code>'array-broadcast)" returns "
     (<code>"(specialized-array-share "(<var> "array new-domain process-args")")")
     " with the proviso that result is forced to be immutable if "(<cv>'new-domain)
     " has more elements (a greater volume) than "(<code>"(array-domain "(<var>'array)")")".")
(<p> "It is an error if the stated assumptions don't hold.")

(<p> (<b> "Example: ")"We code matrix multiplication three different ways, two of which  were motivated by "
     (<a> href: "https://stackoverflow.com/questions/42170477/does-numpy-provide-a-generalized-inner-product" "a Stack Overflow post")"; see the explanations in that post.  In all cases we assume the arguments are specialized arrays.")
(<pre>(<code>"(define (mat-mul-1 A B)
  ;; Use array inner product, which is motivated by
  ;; matrix multiplication
  (array-inner-product A + * B))

(define (mat-mul-2 A B)
  ;; We explicitly calculate the broadcast domain
  ;; and broadcast the array arguments
  ;; before calculating the pairwise products
  (let* ((A* ;; add new length-one axis on right
          (array-insert-axis A 2))
         (B* ;; add new length-one axis on left
          (array-insert-axis B 0))
         (broadcast-domain
          (compute-broadcast-interval (array-domain A*)
                                      (array-domain B*))))
    (array-copy
     ;; Copy the result to a specialized array
     (array-map
      ;; Sum the one-dimensional arrays of products
      (lambda (products)
        (array-reduce + products))
      (array-curry
       ;; Convert the three-dimensional array of
       ;; products to a two-dimensional array of
       ;; one-dimensional arrays of products
       (array-permute
        ;; Move the middle axis to the end
        (array-map
         ;; Calculate the pairwise products of
         ;; A* and B*
         *
         (array-broadcast A* broadcast-domain)
         (array-broadcast B* broadcast-domain))
        (index-last 3 1))
       1)))))

(define (mat-mul-3 A B)
  ;; We rely on implicit broadcasting of
  ;; the array arguments A* and B*
  (let* ((A* (array-insert-axis A 2))
         (B* (array-insert-axis B 0)))
    (array-copy
     (array-map
      (lambda (products)
        (array-reduce + products))
      (array-curry
       (array-permute
        (array-map * A* B*)
        (index-last 3 1))
       1)))))

(define A (list*->array 2 '((1 2) (3 4))))

(define B (list*->array 2 '((1 -2) (-3 4))))

(array->list* (mat-mul-1 A B)) ;; => ((-5 6) (-9 10))

(array->list* (mat-mul-2 A B)) ;; => ((-5 6) (-9 10))

(array->list* (mat-mul-3 A B)) ;; => ((-5 6) (-9 10))"))

(<p> (<b> "Example: ")" We compute the average of the rows of an array and then subtract the average row from each row of the array.  We rely on the implicit automatic broadcasting of the average row to all the rows of the array.")

(<pre>(<code>"(define A
  (list*->array 2 '(( 1  3  4)
                    ( 2 -1 -4)
                    (-6  4  5)
                    (-1  2  3))))


(define average-of-rows
  (array-copy
   (array-map (lambda (column)
                (/ (array-reduce + column)
                   (interval-volume (array-domain column))))
              (array-curry (array-permute A '#(1 0)) 1))))

(array->list* average-of-rows) ;; => (-1 2 2)

(define centered-rows (array-copy (array-map - A average-of-rows)))

(array->list* centered-rows) ;; => ((2 1 2) (3 -3 -6) (-5 2 3) (0 0 1))"))


(format-lambda-list '(array-outer-product operator array1 array2))
(<p> "Implements the outer product of "(<code>(<var>'array1))" and "(<code>(<var>'array2))" with the operator "(<code>(<var>'operator))", similar to the APL function with the same name.")
(<p> "Assumes that "(<code>(<var>'array1))" and "(<code>(<var>'array2))" are arrays and that "(<code>(<var>'operator))" is a procedure of two arguments.  If either "(<cv>'array1)" or "(<cv>'array2)" is a generalized array, it is copied to a specialized array, with elements evaluated in an unspecified order.")
(<p> (<code>(<var>'array-outer-product))" returns the immutable generalized array")
(<pre>(<code>
       "(make-array
 (interval-cartesian-product (array-domain array1)
                             (array-domain array2))
 (lambda args
   (operator (apply (array-getter array1)
                    (take args (array-dimension array1)))
             (apply (array-getter array2)
                    (drop args (array-dimension array1))))))"))
(<p> "It is an error if the arguments do not satisfy these assumptions.")

(<p>(<b> "Example: "))(<pre>(<code>"(let* ((A (make-array (make-interval '#(4)) (lambda (i) (* i 10))))
       (B (make-array (make-interval '#(3)) values))
       (C (array-outer-product + A B)))
  (interval= (array-domain C) (make-interval '#(4 3)))  ;; => #t
  (array-unveil C))"))
(<p> "displays:")
(<pre>(<code>" 0 0 => 0
 0 1 => 1
 0 2 => 2
 1 0 => 10
 1 1 => 11
 1 2 => 12
 2 0 => 20
 2 1 => 21
 2 2 => 22
 3 0 => 30
 3 1 => 31
 3 2 => 32"))

(format-lambda-list '(array-inner-product A f g B #\[ storage-class #\[ mutable? #\] #\]))
(<p> "Assumes that "(<code>(<var>'f))" and "(<code>(<var>'g))" are procedures of two arguments and "(<code>(<var>'A))" and "(<code>(<var>'B))" are arrays of dimension at least one, with the upper and lower bounds of the last axis of "(<code>(<var>'A))" the same as those of the first axis of "(<code>(<var>'B))". If either of the array arguments "(<cv>'A)" and "(<cv>'B)" are generalized arrays, each argument is first copied to a specialized array, with its elements computed in an unspecified order.  Also assumes that "(<cv>'storage-class)" and "(<cv>'mutable?)", if given, are a storage class and a boolean, respectively; if they are not given, then "(<cv>'storage-class)" is assigned the value "(<code>'generic-storage-class)" and "(<cv>'mutable?)" is assigned the value "(<code>'specialized-array-default-mutable?)".")
(<p> (<code>'array-inner-product)" computes the equivalent of")
(<pre>(<code>"(define (array-inner-product "(<var>"A f g B storage-class mutable?")")
  (array-copy
   (array-outer-product
    (lambda ("(<var>"a b")")
      (array-reduce "(<var>'f)" (array-map "(<var>"g a b")")))
    (array-copy (array-curry "(<var>'A)" 1))
    (array-copy (array-curry (array-permute "(<var>'B)" (index-last (array-dimension "(<var>'B)") 0)))))
   "(<cv>'storage-class)"
   "(<cv>'mutable?)"))"))

(<p> "It is an error if the arguments do not satisfy these constraints.")
(<p> "See the extended examples below that use "(<code>'array-inner-product)".")

(format-lambda-list '(array-map f array #\. arrays))
(<p> "Assumes that "(<code>(<var> 'array))", "(<code>"(car "(<var> 'arrays)")")", ... are arrays and "(<code>(<var> 'f))" is a procedure.")
(<p> "If the parameter "(<code>'array-broadcasting?)" is "(<code>'#t)" at the time the procedure is called, then the array arguments are "(<a> href: "#implicit-array-broadcasting" "implicitly broadcast")" before the procedure body is executed; otherwise, it is required that all array arguments have the same domain.")
(<p> "Then "(<code> 'array-map)"
returns a new immutable array with the same domain and getter")
(<pre>
 (<code>
"(lambda multi-index
  (apply "(<var>'f)"
         (map (lambda (g)
                (apply g multi-index))
              (map array-getter
                   (cons "(<var> 'array)" "(<var> 'arrays)")))))"))
(<p> "It is assumed that "(<code>(<var> 'f))" is appropriately defined to be evaluated in this context.")

(<p> "It is expected that "(<code> 'array-map)" and "(<code> 'array-for-each)" will specialize the construction of")
(<pre>
 (<code>
"(lambda multi-index
  (apply "(<var>'f)"
         (map (lambda (g)
                (apply g multi-index))
              (map array-getter
                   (cons "(<var> 'array)"
                         "(<var> 'arrays)")))))"))
(<p> "It is an error to call "(<code> 'array-map)" if its arguments do not satisfy these conditions.")

(<p> (<b> "Note: ")"The ease of constructing temporary arrays without allocating storage makes it trivial to imitate, e.g., Javascript's map with index. For example, we can add the index to each element of an array "(<code>(<var>'a))" by ")
(<pre>
 (<code>
"(array-map +
           a
           (make-array (array-domain a)
                       (lambda (i) i)))"))
(<p> "or even")
(<pre>
 (<code>
"(make-array (array-domain a)
            (let ((a_ (array-getter a)))
              (lambda (i)
                (+ (a_ i) i))))"
))
(<p> (<b> "Example: "))(<pre>(<code>"(let* ((A (make-array (make-interval '#(1 1) '#(5 5)) list))
       (B (array-map (lambda (arg) (apply * arg)) A)))
  (display \"A:\\n\")
  (array-unveil A)
  (display \"B:\\n\")
  (array-unveil B))"))
(<p> "displays:")
(<pre>(<code>"A:
 1 1 => (1 1)
 1 2 => (1 2)
 1 3 => (1 3)
 1 4 => (1 4)
 2 1 => (2 1)
 2 2 => (2 2)
 2 3 => (2 3)
 2 4 => (2 4)
 3 1 => (3 1)
 3 2 => (3 2)
 3 3 => (3 3)
 3 4 => (3 4)
 4 1 => (4 1)
 4 2 => (4 2)
 4 3 => (4 3)
 4 4 => (4 4)
B:
 1 1 => 1
 1 2 => 2
 1 3 => 3
 1 4 => 4
 2 1 => 2
 2 2 => 4
 2 3 => 6
 2 4 => 8
 3 1 => 3
 3 2 => 6
 3 3 => 9
 3 4 => 12
 4 1 => 4
 4 2 => 8
 4 3 => 12
 4 4 => 16"))


(format-lambda-list '(array-for-each f array #\. arrays))
(<p> "Assumes that "(<code>(<var> 'array))", "(<code>"(car "(<var> 'arrays)")")", ... are arrays and "(<code>(<var> 'f))" is a procedure.")
(<p> "If the parameter "(<code>'array-broadcasting?)" is "(<code>'#t)" at the time the procedure is called, then the array arguments are "(<a> href: "#implicit-array-broadcasting" "implicitly broadcast")" before the procedure body is executed; otherwise, it is required that all array arguments have the same domain.")
(<p> "Then "(<code> 'array-for-each)"
calls")
(<pre>
 (<code>
"(interval-for-each
 (lambda multi-index
   (apply "(<var>'f)"
          (map (lambda (g)
                 (apply g multi-index))
               (map array-getter
                    (cons "(<var> 'array)"
                          "(<var> 'arrays)")))))
 (array-domain "(<var> 'array)"))"))
(<p> "In particular, "(<code> 'array-for-each)" always walks the indices of the arrays in lexicographical order.")

(<p> "It is expected that "(<code> 'array-map)" and "(<code> 'array-for-each)" will specialize the construction of")
(<pre>
 (<code>
"(lambda multi-index
  (apply "(<var>'f)"
         (map (lambda (g)
                (apply g multi-index))
              (map array-getter
                   (cons "(<var> 'array)"
                         "(<var> 'arrays)")))))"))
(<p> "It is an error to call "(<code> 'array-for-each)" if its arguments do not satisfy these conditions.")
(<p> (<b> "Example: "))(<pre>(<code>"(let ((A (make-array (make-interval '#(3 3)) list)))
  (display \"A:\\n\")
  (array-unveil A)
  (newline)
  (array-for-each (lambda (entry)
                    (pretty-print (apply + entry)))
                  A))"))
(<p>"displays:")
(<pre>(<code>"A:
 0 0 => (0 0)
 0 1 => (0 1)
 0 2 => (0 2)
 1 0 => (1 0)
 1 1 => (1 1)
 1 2 => (1 2)
 2 0 => (2 0)
 2 1 => (2 1)
 2 2 => (2 2)

0
1
2
1
2
3
2
3
4"))

(format-lambda-list '(array-fold-left operator left-identity array #\. arrays))
(format-lambda-list '(array-fold-right operator right-identity array #\. arrays))
(<p> "These procedures assume that "(<code>(<var>'operator))" is a procedure and "(<code>"(cons "(<var>"array arrays")")")" is a list of arrays.")
(<p> "If the parameter "(<code>'array-broadcasting?)" is "(<code>'#t)" at the time the procedure is called, then the array arguments are "(<a> href: "#implicit-array-broadcasting" "implicitly broadcast")" before the procedure body is executed; otherwise, it is required that all array arguments have the same domain.")
(<p> "Assuming that the array arguments have been broadcast if necessary, these procedures can be defined as:")
(<pre>(<code>"(define (array-fold-left operator left-identity array . arrays)
  (apply interval-fold-left
         operator
         left-identity
         (array-domain array)
         (map array-getter (cons array arrays))))

(define (array-fold-right operator right-identity array . arrays)
  (apply interval-fold-right
         operator
         right-identity
         (array-domain array)
         (map array-getter (cons array arrays))))"))
(<p> "See the notes for "(<code>'interval-fold-left)" and "(<code>'interval-fold-right)".")
(<p> "It is an error if the arguments do not satisfy these assumptions.")

(<p>(<b>"Note: ")" One can fold over empty arrays, which returns "(<cv>'left-identity)" or "(<cv>'right-identity)" as appropriate, but it is an error to call "(<code>'array-reduce)" on an empty array, because "(<code>'array-reduce)" must evaluate at least one element of the argument array.")

(<p>(<b>"Example: ")" One can define an APL-style "(<code>'array-depth)" by:")
(<pre>(<code>
"(define (array-depth a)
  (if (array? a)
      (+ 1 (array-fold-left max 0 (array-map array-depth a)))
      0))"))
(<p> "Here non-arrays have depth 0, and each level of array \"nesting\" increases the depth by 1.")

(<p>(<b>"Example: ")" One can define "(<code>"(array-foldl-on op id array dims)")", which does not fold over the entire array, but computes:")
(<pre>(<code>
"(define (array-foldl-on op id array dims)
  (array-map (lambda (a)
               (array-fold-left op id a))
             (array-curry a dims)))"))
(<p> "which folds over only the "(<code>'dims)" rightmost dimensions and returns an array of results.  (Note that this works even if "
     (<code>'dims)" is "(<code>"(array-dimension array)")", in which case the result is a zero-dimensional array containing the left fold of the entire array.)")

(<p> (<b>"Example: ")"If "(<code>(<var>'op))" is associative with two-sided identity "(<code>(<var>'id))", then "(<code>'array-fold-left)" and "(<code>'array-fold-right)" return the same results, but see:")
(<pre>(<code>
"(define a (make-array (make-interval '#(10)) (lambda (i) i)))
(array-fold-left cons '() a)
=> ((((((((((() . 0) . 1) . 2) . 3) . 4) . 5) . 6) . 7) . 8) . 9)
(array-fold-right cons '() a)
=> (0 1 2 3 4 5 6 7 8 9)
(array-fold-left - 0 a)
=> -45
(array-fold-right - 0 a)
=> -5"))

(format-lambda-list '(array-reduce operator array))

(<p> "Assumes that "(<code>(<var>'array))" is a nonempty array and "(<code>(<var>'operator))" is a procedure of two arguments that is associative, i.e., "(<code>"("(<var>'operator)" ("(<var>'operator)" "(<var>'x)" "(<var>'y)") "(<var>'z)")")" is the same as "(<code>"("(<var>'operator)" "(<var>'x)" ("(<var>'operator)"  "(<var>'y)" "(<var>'z)"))")".")
(<p> "Then "(<code>"(array-reduce "(<var>'operator)" "(<var>'array)")")" can be defined as")
(<pre>
 (<code>
"(define array-reduce
  (let ((reduce-base (list 1))) ;; any unique object
    (lambda (sum array)
      (array-fold-left (lambda (id entry)
                         (if (eq? id reduce-base)
                             entry
                             (sum id entry)))
                       reduce-base
                       array))))"))
(<p> "The implementation is allowed to use the associativity of "(<code>(<var>'operator))" to reorder the computations in "(<code>'array-reduce)". It is an error if the arguments do not satisfy these conditions.")
(<p> (<b>"Example: ")"We consider the finite sum:
$$
S_m=\\sum_{k=1}^m \\frac 1{k^2}.
$$
One can show that
$$
\\frac 1 {m+1}<\\frac{\\pi^2}6-S_m<\\frac 1m.
$$
We attempt to compute this in floating-point arithmetic in two ways. In the first, we apply "
     (<code>'array-reduce)" to an array containing the terms of the series, basically a serial computation.  In the second, we divide the series into blocks of no more than 1,000 consecutive terms, apply "
     (<code>'array-reduce)" to get a new sequence of terms, and repeat the process. The second way is approximately what might happen with GPU computing.")
(<p> " We find with $m=1{,}000{,}000{,}000$: ")
(<pre>
 (<code>
"(define A (make-array (make-interval '#(1) '#(1000000001))
                      (lambda (k)
                        (fl/ (flsquare (inexact k))))))
(define (block-sum A)
  (let ((N (interval-volume (array-domain A))))
    (cond ((<= N 1000)
           (array-reduce fl+ A))
          ((<= N (square 1000))
           (block-sum (array-map block-sum
                                 (array-tile A (vector (integer-sqrt N))))))
          (else
           (block-sum (array-map block-sum
                                 (array-tile A (vector (quotient N 1000)))))))))
(array-reduce fl+ A) => 1.644934057834575
(block-sum A)        => 1.6449340658482325"))
(<p> "Since $\\pi^2/6\\approx{}$"(<code>"1.6449340668482264")", we see  using the first method that the difference $\\pi^2/6-{}$"(<code>"1.644934057834575")"${}\\approx{}$"(<code>"9.013651380840315e-9")" and with the second we have "
     "$\\pi^2/6-{}$"(<code>"1.6449340658482325")"${}\\approx{}$"(<code>"9.99993865491433e-10")".  The true difference should be between $\\frac 1{1{,}000{,}000{,}001}\\approx{}$"(<code>"9.99999999e-10")" and $\\frac 1{1{,}000{,}000{,}000}={}$"(<code>"1e-9")". The difference for the first method is about 10 times too big, and, in fact, will not change further because any further terms, when added to the partial sum, are too small to increase the sum after rounding-to-nearest in double-precision IEEE-754 floating-point arithmetic.")


(format-lambda-list '(array-any predicate array #\. arrays))
(<p> "Assumes "(<code>"(cons "(<var>"array arrays")")")" is a list of arrays.")
(<p> "If the parameter "(<code>'array-broadcasting?)" is "(<code>'#t)" at the time the procedure is called, then the array arguments are "(<a> href: "#implicit-array-broadcasting" "implicitly broadcast")" before the procedure body is executed; otherwise, it is required that all array arguments have the same domain. We'll call the common domain of the (possibly broadcast) arrays "(<code>'interval)".  Also assumes that "(<code>(<var>'predicate))" is a procedure that takes as many arguments as there are arrays and returns a single value.")

(<p> (<code>'array-any)" first computes "(<code>"(apply "(<var>'predicate)" (map (lambda (g_) (apply g_ multi-index)) (map array-getter (cons "(<var>"array arrays")"))))")" to the first element of "(<code>'interval)" in lexicographical order.")
(<p> "If the result of "(<code>(<var>'predicate))" is not "(<code>'#f)", then that result is returned by "(<code>'array-any)".  If the result of "(<code>(<var>'predicate))" is "(<code>'#f)", then "(<code>'array-any)" continues with the second element of "(<code>'interval)", etc., returning the first nonfalse value of  "(<code>(<var>'predicate))".")
(<p> "If "(<code>(<var>'predicate))" always returns  "(<code>'#f)", then "(<code>'array-any)" returns "(<code>'#f)".")
(<p> "If it happens that "(<code>(<var>'predicate))" is applied to "(<code>"(map (lambda (g_) (apply g_ multi-index)) (map array-getter (cons "(<var>"array arrays")")))")" with "(<code>'multi-index)" the last element of "(<code>'interval)", then this last call to "(<code>(<var>'predicate))" is in tail position.")
(<p> "The procedures "(<code>"(array-getter "(<var>'array)")")", etc., are applied only to those values of "(<code>'interval)" necessary to determine the result of "(<code>'array-any)".")
(<p> "It is an error if the arguments do not satisfy these assumptions.")
(<p> (<b> "Example: "))(<pre>(<code>"(let ((A (make-array (make-interval '#(240) '#(250)) values))
      (B (make-array (make-interval '#(250) '#(300)) values)))

  (define (square? n)
    (and (exact? (sqrt n)) n))   ;; return the value

  (array-any square? A)    ;; => #f
  (array-any square? B))   ;; => 256, the first nonfalse value"))

(format-lambda-list '(array-every predicate array #\. arrays))
(<p> "Assumes "(<code>"(cons "(<var>"array arrays")")")" is a list of arrays.")

(<p> "If the parameter "(<code>'array-broadcasting?)" is "(<code>'#t)" at the time the procedure is called, then the array arguments are "(<a> href: "#implicit-array-broadcasting" "implicitly broadcast")" before the procedure body is executed; otherwise, it is required that all array arguments have the same domain. We'll call the common domain of the (possibly broadcast) arrays "(<code>'interval)".  Also assumes that "(<code>(<var>'predicate))" is a procedure that takes as many arguments as there are arrays and returns a single value.")

(<p> (<code>'array-every)" first computes "(<code>"(apply "(<var>'predicate)" (map (lambda (g_) (apply g_ multi-index)) (map array-getter (cons "(<var>"array arrays")"))))")" to the first element of "(<code>'interval)" in lexicographical order.")

(<p> "If the result of "(<code>(<var>'predicate))" is "(<code>'#f)", then that result is returned by "(<code>'array-every)".  If the result of "(<code>(<var>'predicate))" is nonfalse, then "(<code>'array-every)" continues with the second element of "(<code>'interval)", etc., returning the first  value of  "(<code>(<var>'predicate))" that is "(<code>'#f)".")

(<p> "If "(<code>(<var>'predicate))" always returns  a nonfalse value, then the last nonfalse value returned by "(<code>(<var>'predicate))" is also returned by "(<code>'array-every)".")
(<p> "If it happens that "(<code>(<var>'predicate))" is applied to "(<code>"(map (lambda (g_) (apply g_ multi-index)) (map array-getter (cons "(<var>"array arrays")")))")" with "(<code>'multi-index)" the last element of "(<code>'interval)", then this last call to "(<code>(<var>'predicate))" is in tail position.")
(<p> "The procedures "(<code>"(array-getter "(<var>'array)")")", etc., are applied only to those values of "(<code>'interval)" necessary to determine the result of "(<code>'array-every)".")
(<p> "It is an error if the arguments do not satisfy these assumptions.")
(<p> "For an example, see the palindrome example above.")


(format-lambda-list '(array->list array) 'array-rarrow-list)
(<p> "Stores the elements of "(<code>(<var>'array))" into a newly allocated list in lexicographical order.  It is an error if "(<code>(<var>'array))" is not an array.")
(<p> "It is guaranteed that "(<code>"(array-getter "(<var>'array)")")" is called precisely once for each multi-index in "(<code>"(array-domain "(<var>'array)")")" in lexicographical order.")
(<p> (<b> "Example: "))(<pre>(<code>"(let* ((A (make-specialized-array-from-data '#(2 4 6 8)))
       (B (array-reverse A)))
  (pretty-print (array->list A))
  (pretty-print (array->list B)))"))
(<p> "displays:")
(<pre>(<code>"(2 4 6 8)
(8 6 4 2)"))

(format-lambda-list '(list->array interval list #\[ storage-class #\[ mutable? #\] #\]) 'list-rarrow-array)
(<p> "Assumes that "
     (<code>(<var> 'list))" is a list, "
     (<code>(<var> 'interval))" is an interval with volume the same as the length of "(<code>(<var> 'list))",  "
     (<code>(<var> 'storage-class))" is a storage class that can manipulate all the elements of "(<code>(<var> 'list))", and "
     (<code>(<var> 'mutable?))" is a boolean.")
(<p> "Returns a specialized array with domain "(<code>(<var>'interval))" whose elements are the elements of the list "(<code>(<var>'list))" stored in lexicographical order.  The result is mutable depending on the value of "
     (<code>(<var> 'mutable?))".")
(<p> "Any missing optional arguments are assigned the values "(<code>'generic-storage-class)" and "(<code>"(specialized-array-default-mutable?)")", respectively.")
(<p> "It is an error if the arguments do not satisfy these assumptions, or if any element of  "(<code>(<var>'list))" cannot be stored in the body of "(<code>(<var>'storage-class))", and this last error shall be detected and raised.")
(<p> (<b> "Example: "))(<pre>(<code>"(let* ((l (iota 12))
       (A (list->array (make-interval '#(2 2 3)) l))
       (B (list->array (make-interval '#(12)) l)))
  (display \"A:\\n\")
  (array-unveil A)
  (display \"B:\\n\")
  (array-unveil B))"))
(<p> "displays")
(<pre>(<code>"A:
 0 0 0 => 0
 0 0 1 => 1
 0 0 2 => 2
 0 1 0 => 3
 0 1 1 => 4
 0 1 2 => 5
 1 0 0 => 6
 1 0 1 => 7
 1 0 2 => 8
 1 1 0 => 9
 1 1 1 => 10
 1 1 2 => 11
B:
 0 => 0
 1 => 1
 2 => 2
 3 => 3
 4 => 4
 5 => 5
 6 => 6
 7 => 7
 8 => 8
 9 => 9
 10 => 10
 11 => 11"))

(format-lambda-list '(list*->array d nested-list #\[ storage-class #\[ mutable? #\] #\]) 'list*-rarrow-array)
(<p> "Assumes that "(<code>(<var>'d))" is a nonnegative exact integer and, if given, "(<code>(<var>'storage-class))" is a storage class and "(<code>(<var>'mutable?))" is a boolean.")
(<p> "This routine builds a specialized array of dimension "(<code>(<var>'d))", storage class "(<code>(<var>'storage-class))" and mutability "(<code>(<var>'mutable?))" from "(<code>(<var>'nested-list))".  It is assumed that following predicate does not return "(<code>'#f)" when passed "(<code>(<var>'nested-list))" and "(<code>(<var>'d))" as arguments:")
(<pre>(<code>
"(define (check-nested-list dimension nested-data)
    (or (eqv? dimension 0)  ;; anything goes in dimension 0
        (and (list? nested-data)
             (let ((len (length nested-data)))
               (cond ((eqv? len 0)
                      '())
                     ((eqv? dimension 1)
                      (list len))
                     (else
                      (let* ((sublists
                              (map
                               (lambda (l)
                                 (check-nested-list (fx- dimension 1) l))
                               nested-data))
                             (first
                              (car sublists)))
                        (and first
                             (every (lambda (l)
                                      (equal? first l))
                                    (cdr sublists))
                             (cons len first)))))))))"
))
(<p> "In this case, "(<code>'list*->array)" returns an array with domain "(<code>"(make-interval (list->vector (check-nested-list "(<var>"d nested-list")")))")".  If we denote the getter of the result by "(<code>'A_)", then ")
(<pre>(<code>
"(A_ i_0 ... i_d-2 i_d-1)
=> (list-ref (list-ref (... (list-ref nested-list i_0) ...) i_d-2) i_d-1)"))
(<p> "and we assume that this value can be manipulated by "(<code>(<var>'storage-class))".")
(<p> "Any missing optional arguments are assigned the values "(<code>'generic-storage-class)" and "(<code>"(specialized-array-default-mutable?)")", respectively.")
(<p> "Empty and zero-dimensional lists are treated differently; see the discussion for "(<code>'array->list*)".  For example")
(<pre>(<code>
"(list*->array 0 '()) => An array for which ((array-getter (list*->array 0 '()))) => '()
(list*->array 1 '()) => An empty array with domain (make-interval '#(0))
(list*->array 2 '()) => An empty array with domain (make-interval '#(0 0))
(list*->array 2 '(() ())) => An empty array with domain (make-interval '#(2 0))"))
(<p> "It is an error if the arguments do not satisfy these assumptions.")
(<p> (<b> "Example: "))(<pre>(<code>"(let ((A (list*->array 3 '(((1 2 3)
                            (4 5 6))
                           ((7 8 9)
                            (10 11 12))))))
  (array-unveil A))"))
(<p> "displays:")
(<pre>(<code>" 0 0 0 => 1
 0 0 1 => 2
 0 0 2 => 3
 0 1 0 => 4
 0 1 1 => 5
 0 1 2 => 6
 1 0 0 => 7
 1 0 1 => 8
 1 0 2 => 9
 1 1 0 => 10
 1 1 1 => 11
 1 1 2 => 12"))

(format-lambda-list '(object->array object #\[ storage-class #\[ mutable? #\] #\]) 'object-rarrow-array)
(<p> "The same as "(<code>"(list*->array 0 object [ storage-class [ mutable? ] ])")
     ", creates a zero-dimensional specialized array that has the object as its sole element.")
(<p> (<b> "Example: "))
(<pre>(<code>"(array-ref (object->array 42)) ;; => 42"))

(format-lambda-list '(array->list* array) 'array-rarrow-list*)
(<p> "Assumes that "(<code>(<var>'array))" is an array, and returns a newly allocated nested list "(<code>(<var>'nested-list))".  If "(<code>(<var>'array))" is nonempty and has positive dimension and we denote the getter of "(<code>(<var>'array))" by "(<code>'array_)", then "(<code>(<var>'nested-list))" and "(<code>'array_)" satisfy")
(<pre>(<code>
"(array_ i_0 ... i_d-2 i_d-1)
=> (list-ref (list-ref (... (list-ref nested-list i_0) ...) i_d-2) i_d-1)"))
(<p> "Each element of "(<code>(<var>'array))" is accessed once.")
(<p> "If "(<code>(<var>'array))" is zero dimensional, then "(<code>'array->list*)" returns "(<code>"((array-getter "(<var>'array)"))")".  If the argument is an empty array, then the nested lists of the result match the first nonzero dimensions (if any).  For example:")
(<pre>(<code>"(array->list* (make-array (make-interval '#()) (lambda () 2))) => 2 ;; no list
(array->list* (make-array (make-interval '#(0)) error)) => '()
(array->list* (make-array (make-interval '#(0 0)) error)) => '()
(array->list* (make-array (make-interval '#(2 0)) error)) => '(() ())
(array->list* (make-array (make-interval '#(0 2)) error)) => '()"))
(<p> "It is an error if "(<code>(<var>'array))" is not an array.")
(<p> (<b> "Example: "))(<pre>(<code>"(let ((B (array->list* (make-array (make-interval '#(6 6)) (lambda (i j) (/ (+ 1 i j)))))))
  (pretty-print B))"))
(<p>"displays:")
(<pre>(<code>"((1 1/2 1/3 1/4 1/5 1/6)
 (1/2 1/3 1/4 1/5 1/6 1/7)
 (1/3 1/4 1/5 1/6 1/7 1/8)
 (1/4 1/5 1/6 1/7 1/8 1/9)
 (1/5 1/6 1/7 1/8 1/9 1/10)
 (1/6 1/7 1/8 1/9 1/10 1/11))"))

(format-lambda-list '(array->vector array) 'array-rarrow-vector)
(<p> "Stores the elements of "(<code>(<var>'array))" into a newly allocated vector in lexicographical order.  It is an error if "(<code>(<var>'array))" is not an array.")
(<p> "It is guaranteed that "(<code>"(array-getter "(<var>'array)")")" is called precisely once for each multi-index in "(<code>"(array-domain "(<var>'array)")")" in lexicographical order.")
(<p> (<b> "Example: "))(<pre>(<code>"(let* ((A (make-specialized-array-from-data '#(2 4 6 8)))
       (B (array-reverse A)))
  (pretty-print (array->vector A))
  (pretty-print (array->vector B)))"))
(<p>"displays:")
(<pre>(<code>"#(2 4 6 8)
#(8 6 4 2)"))

(format-lambda-list '(vector->array interval vector #\[ storage-class  #\[ mutable? #\] #\]) 'vector-rarrow-array)
(<p> "Assumes that "
     (<code>(<var> 'vector))" is a vector, "
     (<code>(<var> 'interval))" is an interval with volume the same as the length of "(<code>(<var> 'v))",  "
     (<code>(<var> 'storage-class))" is a storage class that can manipulate all the elements of "(<code>(<var> 'vector))", and "
     (<code>(<var> 'mutable?))" is a boolean.")
(<p> "Returns a specialized array with domain "(<code>(<var>'interval))" whose elements are the elements of the vector "(<code>(<var>'vector))" stored in lexicographical order.  The result is mutable depending on the value of "
     (<code>(<var> 'mutable?))".")
(<p> "Any missing optional arguments are assigned the values "(<code>'generic-storage-class)" and "(<code>"(specialized-array-default-mutable?)")", respectively.")
(<p> "It is an error if the arguments do not satisfy these assumptions, or if any element of  "(<code>(<var>'vector))" cannot be stored in the body of "(<code>(<var>'storage-class))", and this last error shall be detected and raised.")
(<p> (<b> "Example: "))(<pre>(<code>"(let* ((v (list->vector (iota 12)))
       (A (vector->array (make-interval '#(2 2 3)) v))
       (B (vector->array (make-interval '#(12)) v)))
  (display \"A:\\n\")
  (array-unveil A)
  (display \"B:\\n\")
  (array-unveil B))"))
(<p> "displays:")
(<pre>(<code>"A:
 0 0 0 => 0
 0 0 1 => 1
 0 0 2 => 2
 0 1 0 => 3
 0 1 1 => 4
 0 1 2 => 5
 1 0 0 => 6
 1 0 1 => 7
 1 0 2 => 8
 1 1 0 => 9
 1 1 1 => 10
 1 1 2 => 11
B:
 0 => 0
 1 => 1
 2 => 2
 3 => 3
 4 => 4
 5 => 5
 6 => 6
 7 => 7
 8 => 8
 9 => 9
 10 => 10
 11 => 11"))


(format-lambda-list '(vector*->array d nested-vector #\[ storage-class  #\[ mutable? #\] #\]) 'vector*-rarrow-array)
(<p> "Assumes that "(<code>(<var>'d))" is a nonnegative exact integer and, if given, "(<code>(<var>'storage-class))" is a storage class and "(<code>(<var>'mutable?))" is a boolean.")
(<p> "This routine builds a specialized array of dimension "(<code>(<var>'d))", storage class "(<code>(<var>'storage-class))", and mutability "(<code>(<var>'mutable?))" from "(<code>(<var>'nested-vector))".  It is assumed that following predicate does not return "(<code>'#f)" when passed "(<code>(<var>'nested-vector))" and "(<code>(<var>'d))" as arguments:")
(<pre>(<code>
"(define (check-nested-vector dimension nested-data)
  (or (eqv? dimension 0)  ;; anything goes in dimension 0
      (and (vector? nested-data)
           (let ((len (vector-length nested-data)))
             (cond ((eqv? len 0)
                    '())
                   ((eqv? dimension 1)
                    (list len))
                   (else
                    (let* ((sublists
                            (vector-map
                             (lambda (l)
                               (check-nested-vector (fx- dimension 1) l))
                             nested-data))
                           (first
                            (vector-ref sublists 0)))
                      (and first
                           (vector-every (lambda (l)
                                           (equal? first l))
                                         sublists)
                           (cons len first)))))))))"))
(<p> "In this case, "(<code>'vector*->array)" returns an array with domain "(<code>"(make-interval (list->vector (check-nested-vector "(<var>"d nested-vector")")))")".  If we denote the getter of the result by "(<code>'A_)", then ")
(<pre>(<code>
"(A_ i_0 ... i_d-2 i_d-1)
=> (vector-ref (vector-ref (... (vector-ref nested-vector i_0) ...) i_d-2) i_d-1)"))
(<p> "and we assume that this value can be manipulated by "(<code>(<var>'storage-class))".")
(<p> "Any missing optional arguments are assigned the values "(<code>'generic-storage-class)" and "(<code>"(specialized-array-default-mutable?)")", respectively.")
(<p> "If the resulting array would be empty or have dimension zero, see the examples for "(<code>'list*->array)".")
(<p> "It is an error if the arguments do not satisfy these assumptions.")
(<p> (<b> "Example: "))(<pre>(<code>"(let ((A (vector*->array 3 '#(#(#(1 2 3)
                                #(4 5 6))
                              #(#(7 8 9)
                                #(10 11 12))))))
  (array-unveil A))"))
(<p> "displays:")
(<pre>(<code>" 0 0 0 => 1
 0 0 1 => 2
 0 0 2 => 3
 0 1 0 => 4
 0 1 1 => 5
 0 1 2 => 6
 1 0 0 => 7
 1 0 1 => 8
 1 0 2 => 9
 1 1 0 => 10
 1 1 1 => 11
 1 1 2 => 12"))

(format-lambda-list '(array->vector* array) 'array-rarrow-vector*)
(<p> "Assumes that "(<code>(<var>'array))" is an array, and returns a newly allocated nested vector "(<code>(<var>'nested-vector))".  If we denote the getter of "(<code>(<var>'array))" by "(<code>'array_)", then "(<code>(<var>'nested-vector))" and "(<code>'array_)" satisfy")
(<pre>(<code>
"(array_ i_0 ... i_d-2 i_d-1)
=> (vector-ref (vector-ref (... (vector-ref nested-vector i_0) ...) i_d-2) i_d-1)"))
(<p> "If "(<code>(<var>'array))" is empty or zero dimensional, then see the examples for "(<code>'array->list*)".:")
(<p> "Each element of "(<code>(<var>'array))" is accessed once.")
(<p> "It is an error if "(<code>(<var>'array))" is not an array.")
(<p> (<b> "Example: "))(<pre>(<code>"(let ((B (array->vector* (make-array (make-interval '#(6 6)) (lambda (i j) (/ (+ 1 i j)))))))
  (pretty-print B))"))
(<p>"displays:")
(<pre>(<code>"#(#(1 1/2 1/3 1/4 1/5 1/6)
  #(1/2 1/3 1/4 1/5 1/6 1/7)
  #(1/3 1/4 1/5 1/6 1/7 1/8)
  #(1/4 1/5 1/6 1/7 1/8 1/9)
  #(1/5 1/6 1/7 1/8 1/9 1/10)
  #(1/6 1/7 1/8 1/9 1/10 1/11))"))

(format-lambda-list '(array-assign! destination source))
(<p> "Assumes that "(<code>(<var>'destination))" is a mutable array and "(<code>(<var>'source))" is an array with the same domain and that the elements of "(<code>(<var>'source))" can be stored into "(<code>(<var>'destination))".")
(<p> (<code>'array-assign!)" evaluates "(<cv>'source)"'s getter to obtain a value, and then applies "(<cv>'destination)"'s setter to that value, for each each multi-index in the common domain of the arguments; that is, it alternates computing the getter of "(<cv>'source)" and the setter of "(<cv>'destination)" at each multi-index (in lexicographical order) in their common domain.")
(<p> "It is an error if the arguments don't satisfy these assumptions.")
(<p> (<b> "Example: "))(<pre>(<code>"(let* ((A (array-copy
           (make-array (make-interval '#(5 5))
                       (lambda (i j) (* i j)))
           generic-storage-class
           #t))    ;; ensure A is mutable
       (D_B (make-interval '#(2 2) '#(5 5)))
       (B (make-array D_B (lambda (i j) 100))))
  (display \"A before assignment:\\n\")
  (pretty-print (array->list* A))
  (array-assign! (array-extract A D_B)
                 B)
  (display \"A after assignment:\\n\")
  (pretty-print (array->list* A)))"))
(<p>"displays:")
(<pre>(<code>"A before assignment:
((0 0 0 0 0)
 (0 1 2 3 4)
 (0 2 4 6 8)
 (0 3 6 9 12)
 (0 4 8 12 16))
A after assignment:
((0 0 0 0 0)
 (0 1 2 3 4)
 (0 2 100 100 100)
 (0 3 100 100 100)
 (0 4 100 100 100))"))
(<p> "See also the "(<a> href: "#gauss-seidel" "Gauss-Seidel")" linear solver example.")

(format-lambda-list '(array-stack k arrays #\[ storage-class #\[ mutable? #\] #\]))
(format-lambda-list '(array-stack! k arrays #\[ storage-class #\[ mutable? #\] #\]))
(<p> "Assumes that "(<code>(<var>'arrays))" is a nonempty list of arrays with identical domains,  "(<code>(<var>'k))" is an exact integer between 0 (inclusive) and the dimension of the array domains (inclusive), and, if given, "(<code>(<var>'storage-class))" is a storage class and "(<code>(<var>'mutable?))" is a boolean.")
(<p> "Returns a specialized array equivalent to")
(<pre>(<code>"(array-copy
 (make-array
  (let (("(<var>'lowers)" (interval-lower-bounds->list (array-domain (car "(<var>'arrays)"))))
        ("(<var>'uppers)" (interval-upper-bounds->list (array-domain (car "(<var>'arrays)"))))
        ("(<var>'N)" (length "(<var>"arrays")")))
    (make-interval
     (list->vector (append (take "(<var>"lowers k")") (cons 0 (drop "(<var>"lowers k")"))))
     (list->vector (append (take "(<var>"uppers k")") (cons "(<var>'N)" (drop "(<var>"uppers k")"))))))
  (let (("(<var>'getters)" (map array-getter "(<var>'arrays)")))
    (lambda indices
      (let (("(<var>'i)" (list-ref "(<var>"indices k")")))
        (apply (list-ref "(<var>"getters i")")
               (append (take "(<var>"indices k")")
                       (drop "(<var>'indices)" (+ "(<var>'k)" 1)))))))))"))
(<p> "In other words we \"stack\" the argument arrays along a new "(<code>(<var>'k))"'th axis, the lower bound of which is set to 0.")
(<p> "Any missing optional arguments are assigned the values "(<code>'generic-storage-class)" and "(<code>"(specialized-array-default-mutable?)")", respectively.")
(<p> "Each element of any of the "(<code>(<var>'arrays))" is accessed once.")
(<p> "It is an error if the arguments do not satisfy these constraints.")
(<p> (<b> "Example: ")"Let's say we have a spreadsheet "(<code>(<var>'A))" and we want to make a new spreadsheet "(<code>(<var>'B))" with the same rows but with the data from only columns 1, 2, 5, and 8.  Using the routine "(<code>'array-display)" we define below, code to do this can look like:")
(<pre>(<code>"(let* ((A
        (make-array
         (make-interval '#(4 10))
         list))
       (column_
        (array-getter                  ;; the getter of ...
         (array-curry                  ;; a 1-D array of the columns of A
          (array-permute A '#(1 0))
          1)))
       (B
        (array-stack                  ;; stack into a new 2-D array ...
         1                            ;; along axis 1 (i.e., columns) ...
         (map column_ '(1 2 5 8)))))  ;; the columns of A you want
  (array-display B))

;;; Displays

(0 1)   (0 2)   (0 5)   (0 8)
(1 1)   (1 2)   (1 5)   (1 8)
(2 1)   (2 2)   (2 5)   (2 8)
(3 1)   (3 2)   (3 5)   (3 8)"))
(<p>"In fact, because "(<code>(<var>'A))" is a generalized array, the only elements of "(<code>(<var>'A))" that are generated are the ones that are assigned as elements of "(<code>(<var>'B))". The result could also be computed in one line:")
(<pre>(<code>
"(array-stack 1 (map (array-getter (array-curry (array-permute A '#(1 0)) 1)) '(1 2 5 8)))"))

(format-lambda-list '(array-decurry AofA #\[ storage-class #\[ mutable? #\] #\]))
(format-lambda-list '(array-decurry! AofA #\[ storage-class #\[ mutable? #\] #\]))
(<p> "Assumes that "(<code>(<var>'AofA))" is a nonempty array of arrays; the elements of "(<code>(<var>'AofA))" are assumed to all have the same (possibly empty) domain. Also assumes that, if given, "(<code>(<var>'storage-class))" is a storage class and "(<code>(<var>'mutable?))" is a boolean.")
(<p> (<code>'array-decurry)" evaluates each array element of "(<code>(<var>'AofA))" once, and evaluates each element of "(<code>'AofA)"'s array elements once.  "(<code>'array-decurry)" returns a specialized array containing the elements of "(<code>(<var>'AofA))"'s array elements; ignoring optional arguments, the result  is equivalent to: ")
(<pre>(<code>
"(let* ((A
        (array-copy AofA))      ;; evaluate all elements of A once
       (A_dim
        (array-dimension A))
       (A_
        (array-getter A))
       (A_D
        (array-domain A))
       (element-domain
        (array-domain (apply A_ (interval-lower-bounds->list A_D))))
       (result-domain
        (interval-cartesian-product A_D element-domain))
       (result
        (make-specialized-array result-domain))
       (curried-result
        (array-curry result (interval-dimension element-domain))))
  (array-for-each array-assign! curried-result A)
  result-array)"))
(<p> "Any missing optional arguments are assigned the values "(<code>'generic-storage-class)" and "(<code>"(specialized-array-default-mutable?)")", respectively.")
(<p> "It is an error if any of these assumptions are not met, or if the given storage class cannot manipulate the elements of "(<code>(<var>'AofA))"'s array elements.")
(<p> (<b> "Example: "))(<pre>(<code>"(let* ((A (list*->array 1 '(1 2 3)))
       (B (list*->array 1 '(4 5 6)))
       (C (list*->array 1 '(7 8 9)))
       (D (list*->array 1 '(10 11 12)))
       (E (list*->array 1 (list A B C D)))
       (F (array-decurry E)))
  (array-every array? E)              ;; => #t
  (array-every
   (lambda (a)
     (interval=
      (array-domain a)
      (make-interval '#(3))))         ;; => #t
   E)
  (interval= (array-domain F)
             (make-interval '#(4 3))) ;; => #t
  (array-unveil F))"))
(<p>"displays:")
(<pre>(<code>" 0 0 => 1
 0 1 => 2
 0 2 => 3
 1 0 => 4
 1 1 => 5
 1 2 => 6
 2 0 => 7
 2 1 => 8
 2 2 => 9
 3 0 => 10
 3 1 => 11
 3 2 => 12"))


(format-lambda-list '(array-append k arrays #\[ storage-class #\[ mutable? #\] #\]))
(format-lambda-list '(array-append! k arrays #\[ storage-class #\[ mutable?  #\] #\]))
(<p> "Assumes that "(<code>(<var>'arrays))" is a nonempty list of arrays with domains that differ at most in the "(<code>(<var>'k))"'th axis,  "(<code>(<var>'k))" is an exact integer between 0 (inclusive) and the dimension of the array domains (exclusive), and, if given, "(<code>(<var>'storage-class))" is a storage class and "(<code>(<var>'mutable?))" is a boolean.")
(<p> "This routine appends, or concatenates, the argument arrays along the "(<var>'k)"'th axis, with the lower bound of this axis set to 0.")
(<p> "Returns a specialized array equivalent to the result of")
(<pre>(<code>"(define (array-append k arrays)
  (let*-values (((axis-subdividers kth-size)
                 ;; compute lower and upper bounds of where along the
                 ;; k'th axis we'll copy each array argument, plus
                 ;; the total size of the kth axis of the result array
                 (let loop ((result '(0))
                            (arrays arrays))
                   (if (null? arrays)
                       (values (reverse result) (car result))
                       (let ((interval (array-domain (car arrays))))
                         (loop (cons (+ (car result)
                                        (- (interval-upper-bound interval k)
                                           (interval-lower-bound interval k)))
                                     result)
                               (cdr arrays))))))
                ((lowers)
                 ;; the domains of the arrays differ only in the kth axis
                 (interval-lower-bounds->vector (array-domain array)))
                ((uppers)
                 (interval-upper-bounds->vector (array-domain array)))
                ((result)
                 ;; the result array
                 (make-specialized-array
                  (let ()
                    (vector-set! lowers k 0)
                    (vector-set! uppers k kth-size)
                    (make-interval lowers uppers))))
                ((translation)
                 ;; a vector we'll use to align each argument
                 ;; array into the proper subarray of the result
                 (make-vector (array-dimension array) 0)))
    (let loop ((arrays arrays)
               (subdividers axis-subdividers))
      (if (null? arrays)
          result
          (let ((array (car arrays)))
            ;; the lower and upper bounds in the kth axis of the result
            ;; where we copy the next array
            (vector-set! lowers k (car subdividers))
            (vector-set! uppers k (cadr subdividers))
            ;; the translation that aligns the next array with the
            ;;  subarray of the result
            (vector-set!
              translation
              k (- (car subdividers)
                   (interval-lower-bound (array-domain array) k)))
            (array-assign!
             (array-extract result (make-interval lowers uppers))
             (array-translate array translation))
            (loop (cdr arrays)
                  (cdr subdividers)))))))"))
(<p> "Each element of any of the "(<code>(<var>'arrays))" is accessed once.")
(<p> "Any missing optional arguments are assigned the values "(<code>'generic-storage-class)" and "(<code>"(specialized-array-default-mutable?)")", respectively.")
(<p> "It is an error if the arguments do not satisfy these constraints.")
(<p>(<b>"Example:")" Given a two-dimensional array $a$ interpreted as a spreadsheet, with the rows and columns indexed starting at 0, one might want to make a new array with row $k$ moved to be the top row.  Then one could do:")
(<pre>(<code>
"(let* ((a (make-array (make-interval '#(4 6)) list))
       (k 2)
       (m (interval-upper-bound (array-domain a) 0))
       (n (interval-upper-bound (array-domain a) 1)))
  (pretty-print
   (array->list* a))
  (newline)
  (pretty-print
   (array->list*
    (array-append
     0
     (list (array-extract a (make-interval (vector k 0) (vector (+ k 1) n)))
           (array-extract a (make-interval (vector k n)))
           (array-extract a (make-interval (vector (+ k 1) 0) (vector m n))))))))"))
(<p> "This prints:")
(<pre>(<code>"(((0 0) (0 1) (0 2) (0 3) (0 4) (0 5))
 ((1 0) (1 1) (1 2) (1 3) (1 4) (1 5))
 ((2 0) (2 1) (2 2) (2 3) (2 4) (2 5))
 ((3 0) (3 1) (3 2) (3 3) (3 4) (3 5)))

(((2 0) (2 1) (2 2) (2 3) (2 4) (2 5))
 ((0 0) (0 1) (0 2) (0 3) (0 4) (0 5))
 ((1 0) (1 1) (1 2) (1 3) (1 4) (1 5))
 ((3 0) (3 1) (3 2) (3 3) (3 4) (3 5)))"))
(<p> "Because this SRFI supports empty arrays, the same code works when $k=0$ (when the second extracted array is empty) or $k=m-1$ (when the third extracted array is empty).")


(format-lambda-list '(array-block AofA #\[ storage-class #\[ mutable? #\] #\]))
(format-lambda-list '(array-block! AofA #\[ storage-class #\[ mutable? #\] #\]))
(<p> "This procedure is an inverse to "(<code>'array-tile)".  It assumes that "(<code>(<var>'AofA))" is a nonempty array of arrays, all of which have the same dimension as "(<code>(<var>'AofA))" itself. It also assumes that, if given, "(<code>(<var>'storage-class))" is a storage class and "(<code>(<var>'mutable?))" is a boolean.")
(<p> "While ignoring the lower and upper bounds of the element arrays, it assumes that those element arrays have widths (as defined by "(<code>'interval-widths)") that allow them to be packed together in the configuration given by their indices in "(<code>(<var>'AofA))".   Assuming that the lower bounds of "(<code>(<var>'AofA))" are zero, we require for success that: ")
(<pre>(<code>"(every
 (lambda (k)                           ;; for each coordinate direction
   (let ((slices                       ;; the \"slices\"
                                       ;; perpendicular to that direction
          (array-curry
           (array-permute AofA (index-first (array-dimension AofA) k))
           (- (array-dimension AofA) 1))))
     (array-every
      (lambda (slice)                  ;; for every slice perpendicular
                                       ;; to direction k
        (let ((slice-kth-width         ;; the kth interval width of the
                                       ;; \"corner\" element
               (interval-width
                (array-domain
                 (apply (array-getter slice)
                        (make-list (- (array-dimension AofA) 1) 0)))
                k)))
          (array-every
           (lambda (a)                 ;; all arrays within slice have the
                                       ;; same width in the kth direction
             (= (interval-width (array-domain a) k)
                slice-kth-width))
           slice)))
      slices)))
 (iota (array-dimension AofA)))"))
(<p> "This procedure then returns a specialized array with lower bounds all zero and with the specified storage class and mutability, whose elements are taken from the array elements of "(<code>(<var>'AofA))" itself. In principle, one could compute the result by appending all the array elements of "(<code>(<var>'AofA))" successively along each coordinate axis of "(<code>(<var>'AofA))", in any order of the axes.  Each element of "(<code>(<var>'AofA))" is accessed once, and each element of "(<code>(<var>'AofA))"'s array elements is accessed once.")
(<p> "Each element of "(<code>(<var>'AofA))" is itself an array; one can copy the contents of each array element of "(<code>(<var>'AofA))" to the result array with the following algorithm:")
(<pre>(<code>"(let* ((A_dim
        (array-dimension AofA))
       (ks
        (list->vector (iota A_dim)))
       (corner-multi-index
        (make-list (fx- A_dim 1) 0))
       (slice-offsets       ;; the indices in the direction of the \"cuts\"
        (vector-map
         (lambda (k)        ;; the direction
           (let* ((pencil   ;; a pencil in that direction
                   (apply
                    (array-getter
                     (array-curry
                      (array-permute AofA (index-last A_dim k))
                      1))
                    corner-multi-index))
                  (pencil_
                   (array-getter pencil))
                  (pencil-size
                   (interval-width (array-domain pencil) 0))
                  (result   ;; sum of all kth interval-widths in pencil
                   (make-vector (fx+ pencil-size 1) 0)))
             (do ((i 0 (fx+ i 1)))
                 ((fx= i pencil-size) result)
               (vector-set! result
                            (fx+ i 1)
                            (fx+ (vector-ref result i)
                                 (interval-width (array-domain (pencil_ i))
                                                 k))))))
         ks))
       (result
        (make-specialized-array
         (make-interval
          (vector-map (lambda (v)
                        (vector-ref v (fx- (vector-length v) 1)))
                      slice-offsets))
         storage-class
         (storage-class-default storage-class))))
  ;; We copy the elements from each input array block to the
  ;; corresponding block in the result array.
  (interval-for-each
   (lambda multi-index
     (let* ((vector-multi-index
             (list->vector multi-index))
            (corner     ;; where the subarray will sit in the result array
             (vector-map (lambda (i k)
                           (vector-ref (vector-ref slice-offsets k) i))
                         vector-multi-index
                         ks))
            (subarray
             (apply array-ref AofA multi-index))
            (rebased-subarray  ;; translate the subarray to corner
             (array-rebase subarray corner)))
       (array-assign! (array-extract result (array-domain rebased-subarray))
                      rebased-subarray)))
   (array-domain AofA)))"))
(<p> "Any missing optional arguments are assigned the values "(<code>'generic-storage-class)" and "(<code>"(specialized-array-default-mutable?)")", respectively.")
(<p> "It is an error if the arguments do not satisfy these assumptions, or if all elements of the result cannot by manipulated by the given storage class.")
(<p>(<b> "Examples: "))
(<pre>(<code>"(array->vector*
 (array-block (list*->array
               2
               (list (list (list*->array 2 '((0 1)
                                             (2 3)))
                           (list*->array 2 '((4)
                                             (5)))
                           (list*->array 2 '((6 7 8)
                                             (9 10 11))))
                     (list (list*->array 2 '((12 13)))
                           (list*->array 2 '((14)))
                           (list*->array 2 '((15 16 17))))))))
=>
#(#(0 1 4 6 7 8)
  #(2 3 5 9 10 11)
  #(12 13 14 15 16 17))

(array-block
 (list*->array
  2
  (list
   (list (list*->array 2 '((0 1)
                           (2 3)))
         (list*->array 2 '((4)
                           (5)))
         (list*->array 2 '((6 7)            ;; these should each have ...
                           (9 10))))        ;; three elements to match ...
   (list (list*->array 2 '((12 13)))
         (list*->array 2 '((14)))
         (list*->array 2 '((15 16 17))))))) ;; this array
=> error"))
(<p> (<b> "Example: Kronecker product: ")" If you have two nonempty arrays "(<cv>'A)" and "(<cv>'B)" of the same dimension with numbers as elements, then the "(<a> href: "https://en.wikipedia.org/wiki/Kronecker_product" "Kronecker product")" of "(<cv>'A)" and "(<cv>'B)" can be computed as")
(<pre>(<code>"(define (Kronecker-product A B)
  (array-block
   (array-map (lambda (a) (array-map (lambda (b) (* a b)) B)) A)))"))
(<p> "Iterated Kronecker products can be used to product "(<a> href: "https://rosettacode.org/wiki/Kronecker_product_based_fractals?oldid=390075#Scheme" "fractal patterns")".")

(format-lambda-list '(array-ref array #\. multi-index))
(<p> "Assumes that "(<code>(<var>'array))" is an array, and  "(<code>(<var>'multi-index))" is a sequence of exact integers.")
(<p> "Returns "(<code>"(apply (array-getter "(<var>'array)") "(<var>'multi-index)")")".")
(<p> "It is an error if "(<code>(<var>'array))" is not an array,  if the number of elements in "(<code>(<var>'multi-index))" is not the the dimension of "(<code>(<var>'array))", or if "(<code>(<var>'multi-index))" is not in the domain of "(<code>(<var>'array))", so, in particular, if "(<code>(<var>'array))" is empty.")
(<p> (<b> "Example: "))(<pre>(<code>"(let ((A (make-array (make-interval '#(10000 10000)) expt)))
  (array-ref A 5 37)  ;; => 72759576141834259033203125
  (array-ref A 37 5)) ;; => 69343957"))

(format-lambda-list '(array-set! array object #\. multi-index))
(<p> "Assumes that "(<code>(<var>'array))" is a mutable array, that "(<code>(<var>'object))" is a value that can be stored within that array, and that "(<code>(<var>'multi-index))" is a sequence of exact integers.")
(<p> "Returns "(<code>"(apply (array-setter "(<var>'array)") "(<var>"object multi-index")")")".")
(<p> "It is an error if "(<code>(<var>'array))" is not a mutable array, if "(<code>(<var>'object))" is not an appropriate value to be stored in that array, if the number of elements in "(<code>(<var>'multi-index))" is not the the dimension of "(<code>(<var>'array))", or if "(<code>(<var>'multi-index))" is not in the domain of "(<code>(<var>'array))", so, in particular, if "(<code>(<var>'array))" is empty.")
(<p> (<b> "Example: "))(<pre>(<code>"(let ((A (array-copy
          (list*->array 1 (iota 1000))
          generic-storage-class
          #t)))   ;; ensure array is mutable
  (array-ref A 500)         ;; => 500
  (array-set! A 'grok 500)
  (array-ref A 500))        ;; => grok"))

(<p>(<b> "Note: ")"In the sample implementation, because "(<code>'array-ref)" and "(<code>'array-set!)" take a variable number of arguments and they must check that "(<code>(<var>'A))" is an array of the appropriate type, programs written in a style using these procedures, rather than the style in which "(<code>'1D-Haar-loop)" is coded below, can take up to three times as long runtime.")

(<p>(<b> "Note: ")"In the sample implementation, checking whether the multi-indices are exact integers and within the domain of the array, and checking whether the value is appropriate for storage into the array, is delegated to the underlying definition of the array argument.  If the first argument is a  specialized array, then these items are checked.  If it is a generalized array, it is up to the programmer whether to define the getter and setter of the array to check the correctness of the arguments.")

(format-lambda-list '(specialized-array-reshape array interval #\[ copy-on-failure? #f #\]))
(<p> "Assumes that "(<code>(<var>'array))" is a specialized array, "(<code>(<var>'interval))" is an interval with the same volume as "(<code>"(array-domain "(<var>'array)")")", and "(<code>(<var>'copy-on-failure?))", if given, is a boolean.")
(<p> "If there is an affine map that takes the multi-indices in "(<code>(<var>'interval))" to the cells in "(<code>"(array-body "(<var>'array)")")" storing the elements of "(<code>(<var>'array))" in lexicographical order, "(<code>'specialized-array-reshape)" returns a new specialized array, with the same body and elements as "(<code>(<var>'array))" and domain "(<code>(<var>'interval))".  The result inherits its mutability from "(<code>(<var>'array))".")
(<p> "If there is not an affine map that takes the multi-indices in "(<code>(<var>'interval))" to the cells storing the elements of "(<code>(<var>'array))" in lexicographical order and "(<code>(<var>'copy-on-failure?))" is "(<code>'#t)", then returns a specialized array copy of "(<code>(<var>'array))" with domain "(<code>(<var>'interval))", storage class "(<code>"(array-storage-class "(<var>'array)")")" and mutability "(<code>"(mutable-array? "(<var>'array)")")".")
(<p> "It is an error if these conditions on the arguments are not met.")
(<p>(<b>"Note: ")"The code in the sample implementation to determine whether there exists an affine map from "(<code>(<var>'interval))" to the multi-indices of the elements of "(<code>(<var>'array))" in lexicographical order is modeled on the corresponding code in the Python library NumPy.")
(<p>(<b> "Note: ")"In the sample implementation, if an array cannot be reshaped and "(<code>(<var>'copy-on-failure?))" is "(<code>'#f)", an error is raised in tail position.  An implementation might want to replace this error call with a continuable exception to give the programmer more flexibility.")
(<p>(<b>"Examples: ")"Reshaping an array is not a Bawden-type array transform.  For example, we use "(<code>'array-display)" defined below to see:")
(<pre>
 (<code>
";;; The entries of A are the multi-indices of the locations

(define A (array-copy (make-array (make-interval '#(3 4)) list)))

(array-display A)

;;; Displays

;;; (0 0)   (0 1)   (0 2)   (0 3)
;;; (1 0)   (1 1)   (1 2)   (1 3)
;;; (2 0)   (2 1)   (2 2)   (2 3)

(array-display (array-permute A '#(1 0)))

;;; Displays

;;; (0 0)   (1 0)   (2 0)
;;; (0 1)   (1 1)   (2 1)
;;; (0 2)   (1 2)   (2 2)
;;; (0 3)   (1 3)   (2 3)

(array-display (specialized-array-reshape A (make-interval '#(4 3))))

;;; Displays

;;; (0 0)   (0 1)   (0 2)
;;; (0 3)   (1 0)   (1 1)
;;; (1 2)   (1 3)   (2 0)
;;; (2 1)   (2 2)   (2 3)

(define B (array-sample A '#(2 1)))

(array-display B)

;;; Displays

;;; (0 0)   (0 1)   (0 2)   (0 3)
;;; (2 0)   (2 1)   (2 2)   (2 3)

(array-display (specialized-array-reshape B (make-interval '#(8)))) => fails

(array-display (specialized-array-reshape B (make-interval '#(8)) #t))

;;; Displays

;;; (0 0)   (0 1)   (0 2)   (0 3)   (2 0)   (2 1)   (2 2)   (2 3)"))
(<p>"The following examples succeed:")
(<pre>
 (<code>"(specialized-array-reshape
 (array-copy (make-array (make-interval '#(2 1 3 1)) list))
 (make-interval '#(6)))
(specialized-array-reshape
 (array-copy (make-array (make-interval '#(2 1 3 1)) list))
 (make-interval '#(3 2)))
(specialized-array-reshape
 (array-reverse (array-copy (make-array (make-interval '#(2 1 3 1)) list)))
 (make-interval '#(6)))
(specialized-array-reshape
 (array-reverse (array-copy (make-array (make-interval '#(2 1 3 1)) list)))
 (make-interval '#(3 2)))
(specialized-array-reshape
 (array-reverse (array-copy (make-array (make-interval '#(2 1 3 1)) list)) '#(#f #f #f #t))
 (make-interval '#(3 2)))
(specialized-array-reshape
 (array-reverse (array-copy (make-array (make-interval '#(2 1 3 1)) list)) '#(#f #f #f #t))
 (make-interval '#(3 1 2 1)))
(specialized-array-reshape
 (array-sample
  (array-reverse (array-copy (make-array (make-interval '#(2 1 4 1)) list))
                 '#(#f #f #f #t))
  '#(1 1 2 1))
 (make-interval '#(4)))
(specialized-array-reshape
 (array-sample (array-reverse (array-copy (make-array (make-interval '#(2 1 4 1)) list))
                              '#(#t #f #t #t))
               '#(1 1 2 1))
 (make-interval '#(4)))"))
(<p>"The following examples raise an exception: ")
(<pre>
 (<code>"(specialized-array-reshape
 (array-reverse (array-copy (make-array (make-interval '#(2 1 3 1)) list)) '#(#t #f #f #f))
 (make-interval '#(6)))
(specialized-array-reshape
 (array-reverse (array-copy (make-array (make-interval '#(2 1 3 1)) list)) '#(#t #f #f #f))
 (make-interval '#(3 2)))
(specialized-array-reshape
 (array-reverse (array-copy (make-array (make-interval '#(2 1 3 1)) list)) '#(#f #f #t #f))
 (make-interval '#(6)))
(specialized-array-reshape
 (array-reverse (array-copy (make-array (make-interval '#(2 1 3 1)) list)) '#(#f #f #t #t))
 (make-interval '#(3 2)))
(specialized-array-reshape
 (array-sample
  (array-reverse (array-copy (make-array (make-interval '#(2 1 3 1)) list))
                 '#(#f #f #f #t))
  '#(1 1 2 1))
 (make-interval '#(4)) )
(specialized-array-reshape
 (array-sample
  (array-reverse (array-copy (make-array (make-interval '#(2 1 4 1)) list))
                 '#(#f #f #t #t))
  '#(1 1 2 1))
 (make-interval '#(4)))"))
(<p> "In the next examples, we start with vector fields, $100\\times 100$ arrays of 4-vectors.  In one example, we reshape each large array to $100\\times 100\\times2\\times2$ vector fields (so we consider each 4-vector as a $2\\times 2$ matrix), and multiply the $2\\times 2$ matrices together.  In the second example, we reshape each 4-vector to a $2\\times 2$ matrix individually, and compare the times.")
(<pre>
 (<code>
"(define interval-flat (make-interval '#(100 100 4)))

(define interval-2x2  (make-interval '#(100 100 2 2)))

(define A (array-copy (make-array interval-flat (lambda args (random-integer 5)))))

(define B (array-copy (make-array interval-flat (lambda args (random-integer 5)))))

(define C (array-copy (make-array interval-flat (lambda args 0))))

(define (2x2-matrix-multiply-into! A B C)
  (let ((C! (array-setter C))
        (A_ (array-getter A))
        (B_ (array-getter B)))
    (C! (+ (* (A_ 0 0) (B_ 0 0))
           (* (A_ 0 1) (B_ 1 0)))
        0 0)
    (C! (+ (* (A_ 0 0) (B_ 0 1))
           (* (A_ 0 1) (B_ 1 1)))
        0 1)
    (C! (+ (* (A_ 1 0) (B_ 0 0))
           (* (A_ 1 1) (B_ 1 0)))
        1 0)
    (C! (+ (* (A_ 1 0) (B_ 0 1))
           (* (A_ 1 1) (B_ 1 1)))
        1 1)))

;;; Reshape A, B, and C to change all the 4-vectors to 2x2 matrices

(time
 (array-for-each 2x2-matrix-multiply-into!
                 (array-curry (specialized-array-reshape A interval-2x2) 2)
                 (array-curry (specialized-array-reshape B interval-2x2) 2)
                 (array-curry (specialized-array-reshape C interval-2x2) 2)))
;;; Displays

;;;    0.015186 secs real time
;;;    0.015186 secs cpu time (0.015186 user, 0.000000 system)
;;;    4 collections accounting for 0.004735 secs real time (0.004732 user, 0.000000 system)
;;;    46089024 bytes allocated
;;;    no minor faults
;;;    no major faults

;;; Reshape each 4-vector to a 2x2 matrix individually

(time
 (array-for-each (lambda (A B C)
                   (2x2-matrix-multiply-into!
                    (specialized-array-reshape A (make-interval '#(2 2)))
                    (specialized-array-reshape B (make-interval '#(2 2)))
                    (specialized-array-reshape C (make-interval '#(2 2)))))
                 (array-curry A 1)
                 (array-curry B 1)
                 (array-curry C 1)))

;;; Displays

;;;    0.039193 secs real time
;;;    0.039193 secs cpu time (0.039191 user, 0.000002 system)
;;;    6 collections accounting for 0.006855 secs real time (0.006851 user, 0.000001 system)
;;;    71043024 bytes allocated
;;;    no minor faults
;;;    no major faults"))

(<h2> (<a> id: "Implementation" "Implementation"))
(<p> "We provide "(<i>'two)" "(<a> href: "https://github.com/gambiteer/srfi-231/tree/231-bis" "sample implementations")" in "(<a> href: "https://github.com/gambit/gambit" "Gambit Scheme")"; the nonstandard techniques used
in the implementation are "(<code>"define-structure")", "(<code>"define-macro")", and DSSSL optional arguments.")

(<p> "The "(<a> href: "https://github.com/gambiteer/srfi-231/blob/231-bis/generic-arrays.scm" "first sample implementation")" catches and reports errors as soon as possible and open codes specialized versions of algorithms for intervals and arrays of dimension no greater than four.")

(<p> "The "(<a> href: "https://github.com/gambiteer/srfi-231/blob/231-bis/mini-arrays.scm" "second, simplified, sample implementation")" has minimal error checking and employs only the general algorithms that are used for dimensions greater than 4.")

(<h2> (<a> id: "relationship" "Relationship to other array libraries"))

(<h3> (<a> id: "NumPy" "NumPy arrays"))
(<p> (<a> href: "https://numpy.org/doc/stable/" "NumPy")" has a popular "(<a> href: "https://numpy.org/doc/stable/reference/index.html" "array library")", upon which  "(<a> href: "https://pytorch.org/" "PyTorch")", a machine-learning tensor library, is built.")
(<p> "We list some of the correspondences between the routines of this SRFI and the array routines of NumPy.  As we are in no way experienced NumPy programmers, we do not claim any level of completeness in this correspondence.")
(<table>
 border: 1
 cellpadding: 10
 cellspacing: 2
 (<tr> (<th> "SRFI 231")
       (<th> "NumPy"))
 (<tr> (<td> "array-assign!")
       (<td> "copyto"))
 (<tr> (<td> "array-domain")
       (<td> "shape"))
 (<tr> (<td> "specialized-array-reshape")
       (<td> "reshape"))
 (<tr> (<td> "array-permute with index-first, index-last, index-rotate, index-swap")
       (<td> "move-axis, transpose, swap-axes"))
 (<tr> (<td> "array-tile")
       (<td> "split, array-split, dsplit, hsplit, vsplit, array slicing notation"))
 (<tr> (<td> "array-reverse")
       (<td> "flip, fliplr, flipud"))
 (<tr> (<td> "Combine array-reverse and array-permute")
       (<td> "rot90"))
 (<tr> (<td> "array-append")
       (<td> "concatenate"))
 (<tr> (<td> "array-stack, array-decurry")
       (<td> "stack, vstack, hstack, dstack, column_stack, row_stack"))
 (<tr> (<td> "array-block")
       (<td> "block"))
 (<tr> (<td> "array-map with array-copy, array-copy!, or array-assign!")
       (<td> "Elementwise array operations"))
 (<tr> (<td> "array-translate, array-rebase")
       (<td> "No correspondence (array indices always start at 0)"))
 (<tr> (<td> "array-sample")
       (<td> "array slicing notation"))
 (<tr> (<td> "array-extract")
       (<td> "array slicing notation"))
 (<tr> (<td> "array-copy and array-copy!")
       (<td> "Use the copy method"))
 (<tr> (<td> "array-reduce")
       (<td> "Use the reduce method"))
 (<tr> (<td> "array-outer-product")
       (<td> "Use the outer method"))
 (<tr> (<td> "Combine array-curry, array-permute, and array-map")
       (<td> "Operations specifying the axes along which they will be performed"))
 (<tr> (<td> "make-array and array-copy or array-copy!")
       (<td> "fromfunction"))
 (<tr> (<td> "make-specialized-array-from-data")
       (<td> "frombuffer, fromstring"))
 (<tr> (<td> "list->array, list*->array, vector->array, vector*->array")
       (<td> "asarray, asanyarray"))
 (<tr> (<td> "array->list*")
       (<td> "tolist"))
 )

(<h3> (<a> id: "othersrfis" "Other SRFIs"))
(<p> "Final SRFIs "(<a> href: "#SRFI-25" "25")", "(<a> href: "#SRFI-47" "47")", "(<a> href: "#SRFI-58" "58")", and "(<a> href: "#SRFI-63" "63")" deal with \"Multi-dimensional Array Primitives\", \"Array\", \"Array Notation\",
and \"Homogeneous and Heterogeneous Arrays\", respectively.  Each of these previous SRFIs deal with what we call in this SRFI
specialized arrays.  Many of the procedures in these previous SRFIs  have corresponding forms in this SRFI.  For example, from "(<a> href: "https://srfi.schemers.org/srfi-63/" "SRFI 63")", we can
translate: ")
(<dl>
 (<dt> (<code> "(array? object)"))
 (<dd> (<code> "(array? object)"))
 (<dt> (<code> "(array-rank A)"))
 (<dd> (<code> "(array-dimension A)"))
 (<dt> (<code> "(make-array prototype k1 ...)"))
 (<dd> (<code> "(make-specialized-array (make-interval (vector k1 ...)))")".")
 (<dt> (<code> "(make-shared-array A mapper k1 ...)"))
 (<dd> (<code> "(specialized-array-share A (make-interval (vector k1 ...)) mapper)"))
 (<dt> (<code> "(array-in-bounds? A index1 ...)"))
 (<dd> (<code> "(interval-contains-multi-index? (array-domain A) index1 ...)"))
 (<dt> (<code> "(array-ref A k1 ...)"))
 (<dd> (<code> "(let ((A_ (array-getter A))) ... (A_ k1 ...) ... )")" or "(<code> "(array-ref A k1 ...)"))
 (<dt> (<code> "(array-set! A object k1 ...)"))
 (<dd> (<code> "(let ((A! (array-setter A))) ... (A! object k1 ...) ...)")" or "(<code> "(array-set! A object k1 ...)"))
 )


(<h3> (<a> id: "Racket" "Racket's array library"))
(<p> "Racket has an extensive "(<a> href: "https://docs.racket-lang.org/math/array.html" "array library")", written by Neil Toronto, as part of its \"Math Library\".  I do not claim to have a complete understanding of Racket's array library, but attempt here to  give a superficial comparison of some aspects of Racket's library with this proposal:")
(<ul>
 (<li> "Racket's "(<a> href: "https://docs.racket-lang.org/math/array_nonstrict.html" "nonstrict arrays")" correspond to our \"generalized arrays\".")
 (<li> "Racket's arrays axes are indexed from zero; this SRFI allows nonzero lower bounds. Thus Racket's library has no need for array-translate.")
 (<li> "Racket's "(<a> href: "https://docs.racket-lang.org/math/array_pointwise.html" "array-map")" is similar to the one in this proposal, except that ours always returns a generalized array.")
 (<li> "Racket's "(<a> href: "https://docs.racket-lang.org/math/array_transform.html" "array-axis-ref")" can be implemented in this SRFI with "(<code>'array-permute)" and "(<code>'array-curry)". Racket's array-axis-permute is similar to our "(<code>'array-permute)".  Both have "(<code>'array-reshape)" and "(<code>'array-append)".  Racket's array-flatten is similar to "(<code>"(array->vector array)")" in this proposal.")
 (<li> "Racket's "(<a> href: "https://docs.racket-lang.org/math/array_fold.html" "array-axis-fold")" can be implemented in this SRFI as"
 (<pre>(<code>
"(define (array-axis-fold arr k f init)
  (array-map (lambda (pencil)
               (array-fold-left f init pencil))
             (array-curry
              (array-permute arr (index-last (array-dimension arr) k))
              1)))"))
 "If one wants what Racket calls a \"strict\" array as a result, apply "(<code>'array-copy)" to the result.  One can define Racket's \"*-axis-*\" procedures similarly.")
 (<li> "Racket's library has specialized mathematical array operations for many math procedures; this library does not.")
 (<li> "Racket's library has "(<a> href: "https://docs.racket-lang.org/math/array_subtypes.html" "flonum and complex flonum arrays")"; this library has similar features, including for various other homogeneous storage types, and is extendable.")
 (<li> "Racket has many procedures to select and recombine data from various axes of arrays, some of which can be simulated in this SRFI with "(<code>'array-permute)", "(<code>'array-curry)", and "(<code>'array-stack)".")
 (<li> "I don't see procedures in Racket's library corresponding to "(<code>'array-curry)", "(<code>'array-decurry)", "(<code>'array-tile)", or "(<code>'array-block)".")
 (<li> "I don't see a procedure in Racket's library that corresponds to specialized-array-share in this SRFI.")
 )

(<h2> (<a> id: "otherexamples" "Other examples"))
(<p> "Image processing applications provided significant motivation for this SRFI.")
(<p> (<a> id: "PGM" (<b> "Manipulating images in PGM format. "))"On a system with eight-bit chars, one
can write procedures to read and write greyscale images in the PGM format of the "(<a> href: "http://netpbm.sourceforge.net/" "Netpbm package")" as follows.  The  lexicographical
order in "(<code>'array-copy)" guarantees the the correct order of execution of the input procedures:")

(<pre>
 (<code>
"(define make-pgm   cons)
(define pgm-greys  car)
(define pgm-pixels cdr)

(define (read-pgm file)

  (define (read-pgm-object port)
    (skip-white-space port)
    (let ((o (read port)))
      ;; to skip the newline or next whitespace
      (read-char port)
      (if (eof-object? o)
          (error \"reached end of pgm file\")
          o)))

  (define (skip-to-end-of-line port)
    (let loop ((ch (read-char port)))
      (if (not (eqv? ch #\\newline))
          (loop (read-char port)))))

  (define (white-space? ch)
    (case ch
      ((#\\newline #\\space #\\tab) #t)
      (else #f)))

  (define (skip-white-space port)
    (let ((ch (peek-char port)))
      (cond ((white-space? ch)
             (read-char port)
             (skip-white-space port))
            ((eqv? ch #\\#)
             (skip-to-end-of-line port)
             (skip-white-space port))
            (else #f))))

  ;; The image file formats defined in netpbm
  ;; are problematical because they read the data
  ;; in the header as variable-length ISO-8859-1 text,
  ;; including arbitrary whitespace and comments,
  ;; and then they may read the rest of the file
  ;; as binary data.
  ;; So we give here a solution of how to deal
  ;; with these subtleties in Gambit Scheme.

  (call-with-input-file
      (list path:          file
            char-encoding: 'ISO-8859-1
            eol-encoding:  'lf)
    (lambda (port)

      ;; We're going to read text for a while,
      ;; then switch to binary.
      ;; So we need to turn off buffering until
      ;; we switch to binary.

      (port-settings-set! port '(buffering: #f))

      (let* ((header  (read-pgm-object port))
             (columns (read-pgm-object port))
             (rows    (read-pgm-object port))
             (greys   (read-pgm-object port)))

        ;; Now we switch back to buffering
        ;; to speed things up.

        (port-settings-set! port '(buffering: #t))

        (make-pgm
         greys
         (array-copy
          (make-array
           (make-interval (vector rows columns))
           (cond ((or (eq? header 'p5)
                      (eq? header 'P5))
                  ;; pgm binary
                  (if (< greys 256)
                      ;; one byte/pixel
                      (lambda (i j)
                        (char->integer
                         (read-char port)))
                      ;; two bytes/pixel,
                      ;;little-endian
                      (lambda (i j)
                        (let* ((first-byte
                                (char->integer
                                 (read-char port)))
                               (second-byte
                                (char->integer
                                 (read-char port))))
                          (+ (* second-byte 256)
                             first-byte)))))
                 ;; pgm ascii
                 ((or (eq? header 'p2)
                      (eq? header 'P2))
                  (lambda (i j)
                      (read port)))
                   (else
                    (error \"not a pgm file\"))))
          (if (< greys 256)
              u8-storage-class
              u16-storage-class)))))))

(define (write-pgm pgm-data file #!optional force-ascii)
  (call-with-output-file
      (list path:          file
            char-encoding: 'ISO-8859-1
            eol-encoding:  'lf)
    (lambda (port)
      (let* ((greys
              (pgm-greys pgm-data))
             (pgm-array
              (pgm-pixels pgm-data))
             (domain
              (array-domain pgm-array))
             (rows
              (fx- (interval-upper-bound domain 0)
                   (interval-lower-bound domain 0)))
             (columns
              (fx- (interval-upper-bound domain 1)
                   (interval-lower-bound domain 1))))
        (if force-ascii
            (display \"P2\" port)
            (display \"P5\" port))
        (newline port)
        (display columns port) (display " " port)
        (display rows port) (newline port)
        (display greys port) (newline port)
        (array-for-each
         (if force-ascii
             (let ((next-pixel-in-line 1))
               (lambda (p)
                 (write p port)
                 (if (fxzero? (fxand next-pixel-in-line 15))
                     (begin
                       (newline port)
                       (set! next-pixel-in-line 1))
                     (begin
                       (display " " port)
                       (set! next-pixel-in-line
                             (fx+ 1 next-pixel-in-line))))))
             (if (fx< greys 256)
                 (lambda (p)
                   (write-u8 p port))
                 (lambda (p)
                   (write-u8 (fxand p 255) port)
                   (write-u8 (fxarithmetic-shift-right p 8)
                             port))))
         pgm-array)))))
"
        ))
(<p> "One can write a procedure to convolve an image with a filter as follows: ")
(<pre>
 (<code>
"(define (array-convolve source filter)
  (let* ((source-domain
          (array-domain source))
         (S_
          (array-getter source))
         (filter-domain
          (array-domain filter))
         (F_
          (array-getter filter))
         (result-domain
          (interval-dilate
           source-domain
           ;; the left bound of an interval is an equality,
           ;; the right bound is an inequality, hence the
           ;; the difference in the following two expressions
           (vector-map -
                       (interval-lower-bounds->vector filter-domain))
           (vector-map (lambda (x)
                         (- 1 x))
                       (interval-upper-bounds->vector filter-domain)))))
    (make-array result-domain
                (lambda (i j)
                  (array-fold-left
                   (lambda (p q)
                     (+ p q))
                   0
                   (make-array
                    filter-domain
                    (lambda (k l)
                      (* (S_ (+ i k)
                             (+ j l))
                         (F_ k l))))))
                )))"))
(<p> "together with some filters")
(<pre>
 (<code>
"(define sharpen-filter
  (list->array
   (make-interval '#(-1 -1) '#(2 2))
   '(0 -1  0
    -1  5 -1
     0 -1  0)))

(define edge-filter
  (list->array
   (make-interval '#(-1 -1) '#(2 2))
   '(0 -1  0
    -1  4 -1
     0 -1  0)))"))
(<p> "Our computations might results in pixel values outside the valid range, so we define ")
(<pre>
 (<code>
"(define (round-and-clip pixel max-grey)
  (max 0 (min (exact (round pixel)) max-grey)))"))
(<p> "We can then compute edges and sharpen a test image as follows: ")
(<pre>
 (<code>
"(define test-pgm (read-pgm \"girl.pgm\"))

(let ((greys (pgm-greys test-pgm)))
  (write-pgm
   (make-pgm
    greys
    (array-map (lambda (p)
                 (round-and-clip p greys))
               (array-convolve
                (pgm-pixels test-pgm)
                sharpen-filter)))
   \"sharper-test.pgm\"))

(let* ((greys (pgm-greys test-pgm))
       (edge-array
        (array-copy
         (array-map
          abs
          (array-convolve
           (pgm-pixels test-pgm)
           edge-filter))))
       (max-pixel
        (array-fold-left max 0 edge-array))
       (normalizer
        (inexact (/ greys max-pixel))))
  (write-pgm
   (make-pgm
    greys
    (array-map (lambda (p)
                 (- greys
                    (round-and-clip (* p normalizer) greys)))
               edge-array))
   \"edge-test.pgm\"))"))

(<p> (<b> "Viewing two-dimensional slices of three-dimensional data. ")"One example might be viewing two-dimensional slices of three-dimensional data in different ways.  If one has a $1024 \\times 512\\times 512$ 3D image of the body stored as a variable "(<code>(<var>'body))", then one could get 1024 axial views, each $512\\times512$, of this 3D body by "(<code> "(array-curry "(<var>'body)" 2)")"; or 512 median views, each $1024\\times512$, by "(<code> "(array-curry (array-permute "(<var>'body)" (index-first 3 1)) 2)")"; or finally 512 frontal views, each again $1024\\times512$ pixels, by "(<code> "(array-curry (array-permute "(<var>'body)" (index-first 3 2)) 2)")"; see "(<a> href: "https://en.wikipedia.org/wiki/Anatomical_plane" "Anatomical plane")".  Note that you want to have the head up in both the median and frontal views, so we use "(<code>'index-first)" to provide the appropriate permutations.")


(<p> (<b> "Calculating second differences of images. ")"For another example, if a real-valued function is defined
on a two-dimensional interval $I$, its second difference in the direction $d$ at the point $x$ is defined as $\\Delta^2_df(x)=f(x+2d)-2f(x+d)+f(x)$,
and this function is defined only for those $x$ for which $x$, $x+d$, and $x+2d$ are all in $I$. See the beginning of the section on \"Moduli of smoothness\" in "(<a> href: "https://www.math.purdue.edu/~lucier/692/related_papers_summaries.html#Wavelets-and-approximation-theory" "these notes on wavelets and approximation theory")" for more details.")
(<p> "Using this definition, the following code computes all second-order forward differences of an image in the directions
$d,2 d,3 d,\\ldots$, defined only on the domains where this makes sense: ")
(<pre>
 (<code>
"(define (all-second-differences image direction)
  (let ((image-domain (array-domain image)))
    (let loop ((i 1)
               (result '()))
      (let ((negative-scaled-direction
             (vector-map (lambda (j)
                           (* -1 j i))
                         direction))
            (twice-negative-scaled-direction
             (vector-map (lambda (j)
                           (* -2 j i))
                         direction)))
        (cond ((interval-intersect
                image-domain
                (interval-translate
                 image-domain
                 negative-scaled-direction)
                (interval-translate
                 image-domain
                 twice-negative-scaled-direction))
               =>
               (lambda (subdomain)
                 (loop
                  (+ i 1)
                  (cons
                   (array-copy
                    (array-map
                     (lambda (f_i f_i+d f_i+2d)
                       (+ f_i+2d
                          (* -2. f_i+d)
                          f_i))
                     (array-extract
                      image
                      subdomain)
                     (array-extract
                      (array-translate
                       image
                       negative-scaled-direction)
                      subdomain)
                     (array-extract
                      (array-translate
                       image
                       twice-negative-scaled-direction)
                      subdomain)))
                   result))))
              (else
               (reverse result)))))))"))
(<p> "We can define a small synthetic image of size 8x8 pixels and compute its second differences in various directions: ")
(<pre>(<code>
"(define image
 (array-copy
  (make-array (make-interval '#(8 8))
              (lambda (i j)
                (exact->inexact (+ (* i i) (* j j)))))))

(define (expose difference-images)
  (pretty-print (map (lambda (difference-image)
                       (list (array-domain difference-image)
                             (array->list* difference-image)))
                     difference-images)))

(begin
  (display \"\\nOriginal image:\\n\")
  (pretty-print (list (array-domain image)
                      (array->list* image)))
  (display
   \"\\nSecond-differences in the direction $k\\times (1,0)$:\\n\")
  (expose (all-second-differences image '#(1 0)))
  (display
   \"\\nSecond-differences in the direction $k\\times (1,1)$:\\n\")
  (expose (all-second-differences image '#(1 1)))
  (display
   \"\\nSecond-differences in the direction $k\\times (1,-1)$:\\n\")
  (expose (all-second-differences image '#(1 -1))))"))
(<p> "On Gambit 4.8.5, this yields (after some hand editing): ")
(<pre>
"Original image:
(#<%%interval #53 dimension: 2 %%volume: 64 lower-bounds: #(0 0) upper-bounds: #(8 8)>
 ((0. 1. 4. 9. 16. 25. 36. 49.)
  (1. 2. 5. 10. 17. 26. 37. 50.)
  (4. 5. 8. 13. 20. 29. 40. 53.)
  (9. 10. 13. 18. 25. 34. 45. 58.)
  (16. 17. 20. 25. 32. 41. 52. 65.)
  (25. 26. 29. 34. 41. 50. 61. 74.)
  (36. 37. 40. 45. 52. 61. 72. 85.)
  (49. 50. 53. 58. 65. 74. 85. 98.)))

Second-differences in the direction $k\\times (1,0)$:
((#<##interval #2 lower-bounds: #(0 0) upper-bounds: #(6 8)>
  ((2. 2. 2. 2. 2. 2. 2. 2.)
   (2. 2. 2. 2. 2. 2. 2. 2.)
   (2. 2. 2. 2. 2. 2. 2. 2.)
   (2. 2. 2. 2. 2. 2. 2. 2.)
   (2. 2. 2. 2. 2. 2. 2. 2.)
   (2. 2. 2. 2. 2. 2. 2. 2.)))
 (#<##interval #3 lower-bounds: #(0 0) upper-bounds: #(4 8)>
  ((8. 8. 8. 8. 8. 8. 8. 8.)
   (8. 8. 8. 8. 8. 8. 8. 8.)
   (8. 8. 8. 8. 8. 8. 8. 8.)
   (8. 8. 8. 8. 8. 8. 8. 8.)))
 (#<##interval #4 lower-bounds: #(0 0) upper-bounds: #(2 8)>
  ((18. 18. 18. 18. 18. 18. 18. 18.)
   (18. 18. 18. 18. 18. 18. 18. 18.))))

Second-differences in the direction $k\\times (1,1)$:
((#<##interval #5 lower-bounds: #(0 0) upper-bounds: #(6 6)>
  ((4. 4. 4. 4. 4. 4.)
   (4. 4. 4. 4. 4. 4.)
   (4. 4. 4. 4. 4. 4.)
   (4. 4. 4. 4. 4. 4.)
   (4. 4. 4. 4. 4. 4.)
   (4. 4. 4. 4. 4. 4.)))
 (#<##interval #6 lower-bounds: #(0 0) upper-bounds: #(4 4)>
  ((16. 16. 16. 16.)
   (16. 16. 16. 16.)
   (16. 16. 16. 16.)
   (16. 16. 16. 16.)))
 (#<##interval #7 lower-bounds: #(0 0) upper-bounds: #(2 2)>
  ((36. 36.)
   (36. 36.))))

Second-differences in the direction $k\\times (1,-1)$:
((#<##interval #8 lower-bounds: #(0 2) upper-bounds: #(6 8)>
  ((4. 4. 4. 4. 4. 4.)
   (4. 4. 4. 4. 4. 4.)
   (4. 4. 4. 4. 4. 4.)
   (4. 4. 4. 4. 4. 4.)
   (4. 4. 4. 4. 4. 4.)
   (4. 4. 4. 4. 4. 4.)))
 (#<##interval #9 lower-bounds: #(0 4) upper-bounds: #(4 8)>
  ((16. 16. 16. 16.)
   (16. 16. 16. 16.)
   (16. 16. 16. 16.)
   (16. 16. 16. 16.)))
 (#<##interval #10 lower-bounds: #(0 6) upper-bounds: #(2 8)>
  ((36. 36.)
   (36. 36.))))")
(<p> "You can see that with differences in the direction of only the first coordinate, the domains of the difference arrays get smaller in the first coordinate while staying the same in the second coordinate, and with differences in the diagonal directions, the domains of the difference arrays get smaller in both coordinates.")



(<p> (<b> "Separable operators. ")"Many multi-dimensional transforms in signal processing are "(<i> 'separable)", in that the multi-dimensional transform can be computed by applying one-dimensional transforms in each of the coordinate directions.  Examples of such transforms include the Fast Fourier Transform and the "(<a> href: "https://arxiv.org/abs/1210.1944" "Fast Hyperbolic Wavelet Transform")".  Each one-dimensional subdomain of the complete domain is called a "(<i> 'pencil)", and the same one-dimensional transform is applied to all pencils in a given direction. Given the one-dimensional array transform, one can define the multidimensional transform as follows:")
(<pre> (<code>"(define (make-separable-transform 1D-transform)
  (lambda (a)
    (let ((n (array-dimension a)))
      (do ((d 0 (fx+ d 1)))
          ((fx= d n))
        (array-for-each
         1D-transform
         (array-curry (array-permute a (index-last n d)) 1))))))"))
(<p> "Here we put each axis in turn at the end and then apply "(<code>'1D-transform)" to each of the pencils along that axis.")
(<p> "Wavelet transforms in particular are calculated by recursively applying a transform to an array and then downsampling the array; the inverse transform recursively downsamples and then applies a transform.  So we define the following primitives: ")
(<pre>(<code>
"(define (recursively-apply-transform-and-downsample transform)
  (lambda (a)
    (let ((sample-vector (make-vector (array-dimension a) 2)))
      (define (helper a)
        (if (fx< 1 (interval-upper-bound (array-domain a) 0))
            (begin
              (transform a)
              (helper (array-sample a sample-vector)))))
      (helper a))))

(define (recursively-downsample-and-apply-transform transform)
  (lambda (a)
    (let ((sample-vector (make-vector (array-dimension a) 2)))
      (define (helper a)
        (if (fx< 1 (interval-upper-bound (array-domain a) 0))
            (begin
              (helper (array-sample a sample-vector))
              (transform a))))
      (helper a))))"))
(<p>  "By adding a single loop that calculates scaled sums and differences of adjacent elements in a one-dimensional array, we can define various "(<a> id: "Haar" "Haar wavelet transforms")" as follows:")
(<pre>(<code>
"(define (1D-Haar-loop a)
  (let ((a_ (array-getter a))
        (a! (array-setter a))
        (n (interval-upper-bound (array-domain a) 0)))
    (do ((i 0 (fx+ i 2)))
        ((fx= i n))
      (let* ((a_i               (a_ i))
             (a_i+1             (a_ (fx+ i 1)))
             (scaled-sum        (fl/ (fl+ a_i a_i+1) (flsqrt 2.0)))
             (scaled-difference (fl/ (fl- a_i a_i+1) (flsqrt 2.0))))
        (a! scaled-sum i)
        (a! scaled-difference (fx+ i 1))))))

(define 1D-Haar-transform
  (recursively-apply-transform-and-downsample 1D-Haar-loop))

(define 1D-Haar-inverse-transform
  (recursively-downsample-and-apply-transform 1D-Haar-loop))

(define hyperbolic-Haar-transform
  (make-separable-transform 1D-Haar-transform))

(define hyperbolic-Haar-inverse-transform
  (make-separable-transform 1D-Haar-inverse-transform))

(define Haar-transform
  (recursively-apply-transform-and-downsample
   (make-separable-transform 1D-Haar-loop)))

(define Haar-inverse-transform
  (recursively-downsample-and-apply-transform
   (make-separable-transform 1D-Haar-loop)))"))
(<p> "We then define an image that is a multiple of a single, two-dimensional hyperbolic Haar wavelet, compute its hyperbolic Haar transform (which should have only one nonzero coefficient), and then the inverse transform:")
(<pre>
 (<code>
"(let ((image
       (array-copy
        (make-array (make-interval '#(4 4))
                    (lambda (i j)
                      (case i
                        ((0) 1.)
                        ((1) -1.)
                        (else 0.)))))))
  (display \"\nInitial image:\n\")
  (pretty-print (list (array-domain image)
                      (array->list* image)))
  (hyperbolic-Haar-transform image)
  (display \"\\nArray of hyperbolic Haar wavelet coefficients: \\n\")
  (pretty-print (list (array-domain image)
                      (array->list* image)))
  (hyperbolic-Haar-inverse-transform image)
  (display \"\\nReconstructed image: \\n\")
  (pretty-print (list (array-domain image)
                      (array->list* image))))"))
(<p> "This yields: ")
(<pre>"Initial image:
(#<##interval #11 lower-bounds: #(0 0) upper-bounds: #(4 4)>
 ((1. 1. 1. 1.)
  (-1. -1. -1. -1.)
  (0. 0. 0. 0.)
  (0. 0. 0. 0.)))

Array of hyperbolic Haar wavelet coefficients:
(#<##interval #11 lower-bounds: #(0 0) upper-bounds: #(4 4)>
 ((0. 0. 0. 0.)
  (2.8284271247461894 0. 0. 0.)
  (0. 0. 0. 0.)
  (0. 0. 0. 0.)))

Reconstructed image:
(#<##interval #11 lower-bounds: #(0 0) upper-bounds: #(4 4)>
 ((.9999999999999996 .9999999999999996 .9999999999999996 .9999999999999996)
  (-.9999999999999996 -.9999999999999996 -.9999999999999996 -.9999999999999996)
  (0. 0. 0. 0.)
  (0. 0. 0. 0.)))
" )
(<p> "In perfect arithmetic, this hyperbolic Haar transform is "(<i>'orthonormal)", in that the sum of the squares of the elements of the image is the same as the sum of the squares of the hyperbolic Haar coefficients of the image.  We can see that this is approximately true here.")

(<p> "We can apply the (nonhyperbolic) Haar transform to the same image as follows: ")
(<pre>(<code>
 "(let ((image
       (array-copy
        (make-array (make-interval '#(4 4))
                    (lambda (i j)
                      (case i
                        ((0) 1.)
                        ((1) -1.)
                        (else 0.)))))))
  (display \"\\nInitial image:\\n\")
  (pretty-print (list (array-domain image)
                      (array->list* image)))
  (Haar-transform image)
  (display \"\\nArray of Haar wavelet coefficients: \\n\")
  (pretty-print (list (array-domain image)
                      (array->list* image)))
  (Haar-inverse-transform image)
  (display \"\\nReconstructed image: \\n\")
  (pretty-print (list (array-domain image)
                      (array->list* image))))"))
(<p> "This yields: ")
(<pre>"Initial image:
(#<##interval #12 lower-bounds: #(0 0) upper-bounds: #(4 4)>
 ((1. 1. 1. 1.)
  (-1. -1. -1. -1.)
  (0. 0. 0. 0.)
  (0. 0. 0. 0.)))

Array of Haar wavelet coefficients:
(#<##interval #12 lower-bounds: #(0 0) upper-bounds: #(4 4)>
 ((0. 0. 0. 0.)
  (1.9999999999999998 0. 1.9999999999999998 0.)
  (0. 0. 0. 0.)
  (0. 0. 0. 0.)))

Reconstructed image:
(#<##interval #12 lower-bounds: #(0 0) upper-bounds: #(4 4)>
 ((.9999999999999997 .9999999999999997 .9999999999999997 .9999999999999997)
  (-.9999999999999997 -.9999999999999997 -.9999999999999997 -.9999999999999997)
  (0. 0. 0. 0.)
  (0. 0. 0. 0.)))")
(<p> "You see in this example that this particular image has two, not one, nonzero coefficients in the two-dimensional Haar transform, which is again approximately orthonormal.")

(<p> (<b> "Matrix multiplication and Gaussian elimination. ")"While we have avoided conflating matrices and arrays, we give here some examples of matrix operations defined using operations from this SRFI.")
(<p> "Given a nonsingular square matrix $A$ we can overwrite $A$ with lower-triangular matrix $L$ with ones on the diagonal and upper-triangular
matrix $U$ so that $A=LU$ as follows. (We assume \"pivoting\" isn't needed.) For example, if "
     "$$A=\\begin{pmatrix} a_{11}&a_{12}&a_{13}\\\\ a_{21}&a_{22}&a_{23}\\\\ a_{31}&a_{32}&a_{33}\\end{pmatrix}=\\begin{pmatrix} 1&0&0\\\\ \\ell_{21}&1&0\\\\ \\ell_{31}&\\ell_{32}&1\\end{pmatrix}\\begin{pmatrix} u_{11}&u_{12}&u_{13}\\\\ 0&u_{22}&u_{23}\\\\ 0&0&u_{33}\\end{pmatrix}$$ then $A$ is overwritten with
$$
\\begin{pmatrix} u_{11}&u_{12}&u_{13}\\\\ \\ell_{21}&u_{22}&u_{23}\\\\ \\ell_{31}&\\ell_{32}&u_{33}\\end{pmatrix}.
$$
The code uses "(<code>'array-map)", "(<code>'array-assign!)", "(<code>'specialized-array-share)", "(<code>'array-extract)", and "(<code>'array-outer-product)".")
(<pre>
 (<code>
"(define (LU-decomposition A)
  ;; Assumes the domain of A is [0,n)\\times [0,n)
  ;; and that Gaussian elimination can be applied
  ;; without pivoting.
  (let ((n
         (interval-upper-bound (array-domain A) 0))
        (A_
         (array-getter A)))
    (do ((i 0 (fx+ i 1)))
        ((= i (fx- n 1)) A)
      (let* ((pivot
              (A_ i i))
             (column/row-domain
              ;; both will be one-dimensional
              (make-interval (vector (+ i 1))
                             (vector n)))
             (column
              ;; the column below the (i,i) entry
              (specialized-array-share A
                                       column/row-domain
                                       (lambda (k)
                                         (values k i))))
             (row
              ;; the row to the right of the (i,i) entry
              (specialized-array-share A
                                       column/row-domain
                                       (lambda (k)
                                         (values i k))))

             ;; the subarray to the right and
             ;; below the (i,i) entry
             (subarray
              (array-extract
               A (make-interval
                  (vector (fx+ i 1) (fx+ i 1))
                  (vector n         n)))))
        ;; Compute multipliers.
        (array-assign!
         column
         (array-map (lambda (x)
                      (/ x pivot))
                    column))
        ;; Subtract the outer product of i'th
        ;; row and column from the subarray.
        (array-assign!
         subarray
         (array-map -
                    subarray
                    (array-outer-product * column row)))))))"))
(<p> "We then define a $4\\times 4$ "(<a> href: "https://en.wikipedia.org/wiki/Hilbert_matrix" "Hilbert matrix")":")
(<pre>
 (<code>
"(define A
  (array-copy
   (make-array (make-interval '#(4 4))
               (lambda (i j)
                 (/ (+ 1 i j))))))

(define (array-display A)

  (define (display-item x)
    (display x) (display \"\\t\"))

  (newline)
  (case (array-dimension A)
    ((1) (array-for-each display-item A) (newline))
    ((2) (array-for-each (lambda (row)
                           (array-for-each display-item row)
                           (newline))
                         (array-curry A 1)))
    (else
     (error \"array-display can't handle > 2 dimensions: \" A))))

(display \"\\nHilbert matrix:\\n\\n\")

(array-display A)

;;; which displays:
;;; 1       1/2     1/3     1/4
;;; 1/2     1/3     1/4     1/5
;;; 1/3     1/4     1/5     1/6
;;; 1/4     1/5     1/6     1/7

(LU-decomposition A)

(display \"\\nLU decomposition of Hilbert matrix:\\n\\n\")

(array-display A)

;;; which displays:
;;; 1       1/2     1/3     1/4
;;; 1/2     1/12    1/12    3/40
;;; 1/3     1       1/180   1/120
;;; 1/4     9/10    3/2     1/2800"))
(<p> "We can now define matrix multiplication as follows to check our result:")
(<pre>
 (<code>
";;; Functions to extract the lower- and upper-triangular
;;; matrices of the LU decomposition of A.

(define (L a)
  (let ((a_ (array-getter a))
        (d  (array-domain a)))
    (make-array
     d
     (lambda (i j)
       (cond ((= i j) 1)        ;; diagonal
             ((> i j) (a_ i j)) ;; below diagonal
             (else 0))))))      ;; above diagonal

(define (U a)
  (let ((a_ (array-getter a))
        (d  (array-domain a)))
    (make-array
     d
     (lambda (i j)
       (cond ((<= i j) (a_ i j)) ;; diagonal and above
             (else 0))))))       ;; below diagonal

(display \"\\nLower triangular matrix of decomposition of Hilbert matrix:\\n\\n\")
(array-display (L A))

;;; which displays:
;;; 1       0       0       0
;;; 1/2     1       0       0
;;; 1/3     1       1       0
;;; 1/4     9/10    3/2     1


(display \"\\nUpper triangular matrix of decomposition of Hilbert matrix:\\n\\n\")
(array-display (U A))

;;; which displays:
;;; 1       1/2     1/3     1/4
;;; 0       1/12    1/12    3/40
;;; 0       0       1/180   1/120
;;; 0       0       0       1/2800

;;; We'll define a brief, not-very-efficient matrix multiply procedure.

(define (matrix-multiply A B)
  (array-inner-product A + * B))

;;; We'll check that the product of the result of LU
;;; decomposition of A is again A.

(define product (matrix-multiply (L A) (U A)))

(display \"\\nProduct of lower and upper triangular matrices \\n\")
(display \"of LU decomposition of Hilbert matrix:\\n\\n\")
(array-display product)

;;; which displays:
;;; 1       1/2     1/3     1/4
;;; 1/2     1/3     1/4     1/5
;;; 1/3     1/4     1/5     1/6
;;; 1/4     1/5     1/6     1/7"))
(<p> (<b> (<a> href: "https://en.wikipedia.org/w/index.php?title=Conway%27s_Game_of_Life&oldid=1071836488" "Conway's Game of Life")". ")"Alex Harsányi "(<a> href: "https://racket.discourse.group/t/game-of-life-using-math-array/584" "implemented")" Conway's Game of Life using Racket's "(<a> href: "https://docs.racket-lang.org/math/array.html" "array library")"; here we implement the game using this SRFI.")
(<p> "Our strategy is to extend the original array periodically to an array dilated by one row and column above and below, left and right: ")
(<pre>(<code>
"(define (array-pad-periodically a N)
  ;; Pad a periodically with N rows and columns top and bottom, left and right.
  ;; Assumes that the domain of a has zero lower bounds.
  ;; Returns a generalized array.
  (let* ((domain (array-domain a))
         (m      (interval-upper-bound domain 0))
         (n      (interval-upper-bound domain 1))
         (a_     (array-getter a)))
    (make-array (interval-dilate domain (vector (- N) (- N)) (vector N N))
                (lambda (i j)
                  (a_ (modulo i m) (modulo j n))))))

(define (neighbor-count a)
  (let* ((big-a      (array-copy (array-pad-periodically a 1)
                                 (array-storage-class a)))
         (domain     (array-domain a))
         (translates (map (lambda (translation)
                            (array-extract (array-translate big-a translation)
                                           domain))
                          '(#(1 0) #(0 1) #(-1 0) #(0 -1)
                            #(1 1) #(1 -1) #(-1 1) #(-1 -1)))))
    ;; Returns a generalized array that contains the number
    ;; of 1s in the 8 cells surrounding each cell in the original array.
    (apply array-map + translates)))

(define (game-rules a neighbor-count)
  ;; a is a single cell, neighbor-count is the count of 1s in
  ;; its 8 neighboring cells.
  (if (= a 1)
      (if (or (= neighbor-count 2)
              (= neighbor-count 3))
          1 0)
      ;; (= a 0)
      (if (= neighbor-count 3)
          1 0)))

(define (advance a)
  ;; Returns a specialized array
  (array-copy
   (array-map game-rules a (neighbor-count a))
   (array-storage-class a)))

(define glider
  (list*->array
   2
   '((0 0 0 0 0 0 0 0 0 0)
     (0 0 1 0 0 0 0 0 0 0)
     (0 0 0 1 0 0 0 0 0 0)
     (0 1 1 1 0 0 0 0 0 0)
     (0 0 0 0 0 0 0 0 0 0)
     (0 0 0 0 0 0 0 0 0 0)
     (0 0 0 0 0 0 0 0 0 0)
     (0 0 0 0 0 0 0 0 0 0)
     (0 0 0 0 0 0 0 0 0 0)
     (0 0 0 0 0 0 0 0 0 0))
   u1-storage-class))

(define (generations a N)
  (do ((i 0 (fx+ i 1))
       (a a  (advance a)))
      ((fx= i N))
    (newline)
    (pretty-print (array->list* a))))

(generations glider 5)"))
(<p> "which prints")
(<pre>(<code>
"((0 0 0 0 0 0 0 0 0 0)
 (0 0 1 0 0 0 0 0 0 0)
 (0 0 0 1 0 0 0 0 0 0)
 (0 1 1 1 0 0 0 0 0 0)
 (0 0 0 0 0 0 0 0 0 0)
 (0 0 0 0 0 0 0 0 0 0)
 (0 0 0 0 0 0 0 0 0 0)
 (0 0 0 0 0 0 0 0 0 0)
 (0 0 0 0 0 0 0 0 0 0)
 (0 0 0 0 0 0 0 0 0 0))

((0 0 0 0 0 0 0 0 0 0)
 (0 0 0 0 0 0 0 0 0 0)
 (0 1 0 1 0 0 0 0 0 0)
 (0 0 1 1 0 0 0 0 0 0)
 (0 0 1 0 0 0 0 0 0 0)
 (0 0 0 0 0 0 0 0 0 0)
 (0 0 0 0 0 0 0 0 0 0)
 (0 0 0 0 0 0 0 0 0 0)
 (0 0 0 0 0 0 0 0 0 0)
 (0 0 0 0 0 0 0 0 0 0))

((0 0 0 0 0 0 0 0 0 0)
 (0 0 0 0 0 0 0 0 0 0)
 (0 0 0 1 0 0 0 0 0 0)
 (0 1 0 1 0 0 0 0 0 0)
 (0 0 1 1 0 0 0 0 0 0)
 (0 0 0 0 0 0 0 0 0 0)
 (0 0 0 0 0 0 0 0 0 0)
 (0 0 0 0 0 0 0 0 0 0)
 (0 0 0 0 0 0 0 0 0 0)
 (0 0 0 0 0 0 0 0 0 0))

((0 0 0 0 0 0 0 0 0 0)
 (0 0 0 0 0 0 0 0 0 0)
 (0 0 1 0 0 0 0 0 0 0)
 (0 0 0 1 1 0 0 0 0 0)
 (0 0 1 1 0 0 0 0 0 0)
 (0 0 0 0 0 0 0 0 0 0)
 (0 0 0 0 0 0 0 0 0 0)
 (0 0 0 0 0 0 0 0 0 0)
 (0 0 0 0 0 0 0 0 0 0)
 (0 0 0 0 0 0 0 0 0 0))

((0 0 0 0 0 0 0 0 0 0)
 (0 0 0 0 0 0 0 0 0 0)
 (0 0 0 1 0 0 0 0 0 0)
 (0 0 0 0 1 0 0 0 0 0)
 (0 0 1 1 1 0 0 0 0 0)
 (0 0 0 0 0 0 0 0 0 0)
 (0 0 0 0 0 0 0 0 0 0)
 (0 0 0 0 0 0 0 0 0 0)
 (0 0 0 0 0 0 0 0 0 0)
 (0 0 0 0 0 0 0 0 0 0))"))


(<p> (<b> (<a> id: "gauss-seidel" "Iterative methods for solving linear systems. "))"We give an extended example how one might program the "(<a> href: "https://en.wikipedia.org/wiki/Jacobi_method" "Jacobi")" and "(<a> href: "https://en.wikipedia.org/wiki/Gauss%E2%80%93Seidel_method" "Gauss-Seidel")" iterative methods for some linear systems of equations.")
(<p> "We first define a procedure to compute the "(<a> href: "https://en.wikipedia.org/wiki/Matrix_norm#Frobenius_norm" "Frobenius norm")" of the difference between two arrays:")

(<pre>(<code>"(define (frobenius X Y)
  (flsqrt (array-fold-left (lambda (sum x y)
                             (fl+ sum (flsquare (fl- x y))))
                           0. X Y)))"))

(<p>"As an example, we will compute approximate solutions to "(<a> href: "https://en.wikipedia.org/wiki/Laplace%27s_equation" "Laplace's equation")" using the "(<a> href: "https://en.wikipedia.org/wiki/Five-point_stencil#In_two_dimensions" "five-point stencil")" approximation to the Laplacian operator. We assume that we're given boundary values of the solution.")

(<p> "For our test problem the domain is the interval $[0,1]^2$; we approximate the solution at the points $(ih,jh)$, where $h=1/N$ is the mesh spacing and we compute on a $(N+1)\\times (N+1)$ grid.  The value of the approximate solution is given on the boundary, where either $ih$ or $jh$ equals $0$ or $1$, and we need to compute the approximate values at interior grid points.")

(<p>"The function we want to approximate is an exact solution to both the continuous and discrete problems, $u(x,y)=x^2-y^2$:")
(<pre>(<code>
"(define N 32)

(define exact-result   ;; x^2-y^2 is harmonic.
  (array-copy!
   (make-array (make-interval (vector (+ N 1) (+ N 1)))
               (lambda (i j)
                 (let ((x (inexact (/ i N)))
                       (y (inexact (/ j N))))
                   (fl- (flsquare x) (flsquare y)))))
   generic-storage-class
   #t))"))

(<p>"The iteration stops when either (a) a maximum number of iterations is reached, or (b) the Frobenius norm of the difference between the exact and approximate solution is less than a tolerance.  (The tolerance is chosen based on some theory.)")
(<pre>(<code>
"(define tolerance (inexact (/ N)))
(define max-iterations 20000)"))

(<p>" We compute the initial array for the iteration, which has the correct boundary values but is zero in the interior of the grid:")
(<pre>(<code>
"(define X (array-copy! exact-result))

(let ((interior (interval-dilate (array-domain X) '#(1 1) '#(-1 -1))))
  (array-assign! (array-extract X interior)
                 (make-array interior (lambda args 0.))))"))


(<p> "The basic iteration is the same for the Jacobi and Gauss-Seidel iterations, it depends only on whether the output array where the computed elements are stored is different from the input array: ")

(<pre>(<code>"(define (jacobi-iteration! OUT IN)
  ;; A single iteration for approximately solving the two-dimensional linear
  ;; system derived from a finite difference method for Laplace's equation
  ;; If IN and OUT are different, this is a Jacobi iteration.
  ;; If IN and OUT are the same, this is a Gauss-Seidel iteration.
  (let ((interior (interval-dilate (array-domain IN) '#(1 1)  '#(-1 -1))))
    (array-assign!
     (array-extract OUT interior)
     (apply array-map
            (lambda (left right up down)
              (fl* 0.25 (fl+ left right up down)))
            (map (lambda (translation)
                   (array-extract (array-translate IN translation)
                                  interior))
                 '(#(0 -1) #(0 1) #(-1 0) #(1 0)))))))"))

(<p> "For the Jacobi method, we maintain two arrays of approximations, and alternately use each of them as the source and the destination of the basic computation:")
(<pre>(<code>
"(define (jacobi-2d X iterations tolerance exact-answer)
  (let* ((X_0 (array-copy X))
         (X_1 (array-copy X_0)))
    (let loop ((n 0)
               (X_k X_0)
               (X_k+1 X_1))
      (jacobi-iteration! X_k+1 X_k)
      (if (and (fxzero? (fxremainder n 10))
               (or (fx>= n iterations)
                   (fl< (frobenius exact-answer X_k+1) tolerance)))
          (begin
            (pretty-print (list jacobi-iterations: n
                                error: (frobenius exact-answer X_k+1)))
            X_k+1)
          ;; Swap X_k and X_k+1
          (loop (fx+ n 1) X_k+1 X_k)))))"))

(<p> "The Gauss-Seidel iteration overwrites the input array during the computation, so we need only maintain one array.  We add an option to alternate forward and backward iterations:")
(<pre>(<code>"(define (gauss-seidel-2d X iterations tolerance exact-answer
                         #!optional (symmetric? #t))
  (let* ((X_0 (array-copy X)))
    (let loop ((n 0)
               (X_k X_0))
      (jacobi-iteration! X_k X_k)                   ;; forward gauss-seidel
      (if symmetric?
          (let ((reversed (array-reverse X_k)))
            (jacobi-iteration! reversed reversed))) ;; backward gauss-seidel
      (if (and (fxzero? (fxremainder n 10))
               (or (fx>= n iterations)
                   (fl< (frobenius exact-answer X_k) tolerance)))
          (begin
            (pretty-print (list gauss-seidel-iterations: n
                                error: (frobenius exact-answer X_k)
                                symmetric?: symmetric?))
            X_k)
          (loop (fx+ n 1) X_k)))))"))
(<p> "The reverse pass relies on the fact that "(<code>'array-assign!)" traverses the multi-indices in lexicographical order.")
(<p>"Finally, we can compute some examples:")
(<pre>(<code>
"(define jacobi-result
  (time (jacobi-2d X max-iterations tolerance exact-result)))

(define symmetric-gauss-seidel-result
  (time (gauss-seidel-2d X max-iterations tolerance exact-result)))

(define gauss-seidel-result
  (time (gauss-seidel-2d X max-iterations tolerance exact-result #f)))"))
(<p>"We see the results:")
(<pre>(<code>
"(jacobi-iterations: 470 error: .030765499084941455)
(time (jacobi-2d X max-iterations tolerance exact-result))
    0.033253 secs real time
    0.033187 secs cpu time (0.032218 user, 0.000969 system)
    no collections
    12028176 bytes allocated
    1478 minor faults
    no major faults
    119398257 cpu cycles
(gauss-seidel-iterations: 120 error: .028487692987866426 symmetric?: #t)
(time (gauss-seidel-2d X max-iterations tolerance exact-result))
    0.017056 secs real time
    0.017014 secs cpu time (0.014501 user, 0.002513 system)
    no collections
    6401352 bytes allocated
    784 minor faults
    no major faults
    61235808 cpu cycles
(gauss-seidel-iterations: 240 error: .02876354995927427 symmetric?: #f)
(time (gauss-seidel-2d X max-iterations tolerance exact-result #f))
    0.017128 secs real time
    0.017097 secs cpu time (0.017096 user, 0.000001 system)
    no collections
    6160840 bytes allocated
    753 minor faults
    no major faults
    61501869 cpu cycles"))
(<p> "We see that in this instance alternating the direction of the Gauss-Seidel iteration doesn't improve performance.")

(<p> (<b> "Inner products. ")"Our "(<code>'array-inner-product)" procedure differs from that found in APL in a number of ways, including that the result is always an array, never a scalar.")
(<p> "We take some examples from the "(<a> href: "https://www.dyalog.com/uploads/aplx/APLXLangRef.pdf" "APLX Language Reference")":")
(<pre>
 (<code>
";; Examples from
;; http://microapl.com/apl_help/ch_020_020_880.htm

(define TABLE1
  (list->array
   (make-interval '#(3 2))
   '(1 2
     5 4
     3 0)))

(define TABLE2
  (list->array
   (make-interval '#(2 4))
   '(6 2 3 4
     7 0 1 8)))

(array-display (inner-product TABLE1 + * TABLE2))

;;; Displays
;;; 20      2       5       20
;;; 58      10      19      52
;;; 18      6       9       12

(define X (list*->array 1 '(1 3 5 7)))

(define Y (list*->array 1 '(2 3 6 7)))

(array->list* (array-inner-product X + (lambda (x y) (if (= x y) 1 0)) Y))
=>
2"))
(<h2> (<a> id: "Acknowledgments" "Acknowledgments"))
(<p> "The SRFI author thanks Edinah K Gnang, John Cowan, Sudarshan S Chawathe, Jamison Hope, Per Bothner,  Alex Shinn, Jens Axel Søgaard, and Marc Nieper-Wißkirchen for their comments and suggestions, and Arthur A. Gleckler, SRFI Editor, for his guidance and patience.")
(<h2> (<a> id: "References" "References"))
(<ol>
 (<li> (<a> id: 'bawden href: "https://groups.google.com/g/comp.lang.scheme/c/7nkx58Kv6RI/m/a5hdsduFL2wJ" "\"multi-dimensional arrays in R5RS?\"")
       ", by Alan Bawden.")
 (<li> (<a> id: 'SRFI-4  href: "https://srfi.schemers.org/srfi-4/"  "SRFI 4:  Homogeneous Numeric Vector Datatypes")", by Marc Feeley.")
 (<li> (<a> id: 'SRFI-25 href: "https://srfi.schemers.org/srfi-25/" "SRFI 25: Multi-dimensional Array Primitives")", by Jussi Piitulainen.")
 (<li> (<a> id: 'SRFI-47 href: "https://srfi.schemers.org/srfi-47/" "SRFI 47: Array")", by Aubrey Jaffer.")
 (<li> (<a> id: 'SRFI-58 href: "https://srfi.schemers.org/srfi-58/" "SRFI 58: Array Notation")", by Aubrey Jaffer.")
 (<li> (<a> id: 'SRFI-63 href: "https://srfi.schemers.org/srfi-63/" "SRFI 63: Homogeneous and Heterogeneous Arrays")", by Aubrey Jaffer.")
 (<li> (<a> id: 'SRFI-164 href: "https://srfi.schemers.org/srfi-164/" "SRFI 164: Enhanced multi-dimensional Arrays")", by Per Bothner."))
(<h2> (<a> id: "Copyright" "Copyright"))
(<p> (<unprotected> "&copy;")" 2016, 2018, 2020, 2022, 2024, 2025 Bradley J Lucier. All Rights Reserved.")
(<p> "Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: ")
(<p> "The above copyright notice and this permission notice (including the next paragraph) shall be included in all copies or substantial portions of the Software.")
(<p> " THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
")
(<hr>)
(<address> "Editor: " (<a> href: "mailto:srfi-editors+at+srfi+dot+schemers+dot+org" "Arthur A. Gleckler"))
))))))
