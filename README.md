# Choiceless grapher 

The Choiceless Grapher can produce any size of graph of the implication relationships between the consequences of the axiom of choice, [as found here](http://consequences.emich.edu/conseq.htm), with an option on the style of nodes: you can either have the Howard-Rubin (HR) numbering of the forms ("numbers"), or the full LaTeX-formatted statements ("fancy"). It's online as an [app here](http://cgraph.inters.co).

This project is inspired by and based on the **Consequences of the Axiom of Choice Project**, the encyclopedia of set theory without the axiom of choice, by *Prof. Paul Howard and Prof. Jean E. Rubin*. I thank Paul Howard for providing me with the original implication matrix (book1), a tex document with the form statements in LaTeX form, and permision to use these files, which can be found in the folder "Howard-Rubin-data". 

An overview of the program is given below. A paper with a full description and explanation of the code will appear. Until then, you can find posts about this in my ["Boole's ring"](https://boolesrings.org/ioanna/). A big **thank you** to my teammate [Max Rottenkolber](http://mr.gy) over at [interstellar ventures](http://inters.co) for showing me the light (Common Lisp), and for hosting this app:

## The Website, aka the CGraph app

The easiest way to use this program is to use its online app here: [cgraph.inters.co](http://cgraph.inters.co). Just enter the HR. numbers of the axioms you want to draw, possibly change the options and hit "Request diagram".

The website has only minimal information, but you can [read more here](https://boolesrings.org/ioanna/2016/12/13/choiceless-grapher-app/).

If you want very large diagrams (more than 70 or 80 forms)*, or if you prefer to work in a CL REPL, do use the program as described below.

(*) The web app can indeed create very large diagrams (even the full diagram) but it takes some time, and if you need more than one, it's probably faster to use jeffrey in a CL REPL.

## DISCLAIMER

**THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND WHATSOEVER.**

## The program

### Requirements

* Common-Lisp: I have only tested this with **SBCL** or **CCL**  but it should work in any implementation that [external-program](https://github.com/sellout/external-program) supports. Please let me know if you check this!
* [Graphviz](www.graphviz.org/) (`apt-get install graphviz`)
* [Quicklisp](www.quicklisp.org)
* It only works in Linux. Windows and Macintosh support are no longer on the to-do list, since the program is accessible via its web-interface. *If you are interested in having these OS supported please send me a message or leave a comment.*
* The package `labelmaker` also requires `/bin/bash`, `pdflatex`, and `convert`. 

### Installation
Install this package using quicklisp ([installation instructions](https://www.quicklisp.org/beta/#installation)) and git ([installation instructions](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)) as follows:

* Create a folder called `jeffrey` in `quicklisp/local-projects/`,
* Navigate to this folder in a terminal and type `git init` and `git clone git@github.com:ioannad/jeffrey.git`. Alternatively otherwise download the cohntents of this repository to this folder. 

### Load the Choiceless Grapher

Open a Common Lisp REPL and type in (evaluate)

`(ql:quickload "jeffrey")`.

### Drawing the diagram between a given list of form HR numbers

If '(a b c ..) is the list of form numbers (only numbers, without parameters or equivalent form letters), whose relationships you wish to graph, and if you want to save the diagram in the file "filename", then evaluate:

`(graph '(a b c ...) "filename" "style")`

where "style" should be either "numbers" to get the numbers of the nodes in the diagram, or "fancy" to get the full LaTeX-formatted statements of the nodes in the diagram. "fancy" is still experimental and doesn't work well for very large diagrams, in the magnitude of the full one (goes over 13 meters in width). 

### Drawing a random diagram of a given size

You can also draw the implication diagram of a pseudo-random collection of forms, of a given size, as follows (for size 6):

`(random-graph 6 "filename" "style")` 

where "style", as above, should be either "numbers" or "fancy". 

### Drawing the consequences or  of a list of forms

Similarly, you can draw the implication diagram of a list of forms (e.g. of `'(8 85)`) as follows:

`(graph-descendants '(8 85) "filename" "style")`

### Output format

The default output is no longer pdf, as there is an issue with the borders of the fancy labels. The current default is `png` but you can output any filetype supported by dot (svg, ps,...) with, for example:

`(graph '(0 1 2 3 23) "test" "fancy" "ps")`

or 

`(random-graph 5 "random5" "fancy" "svg")`

The resulting images and dot files will appear in `~/quicklisp/local-projects/jeffrey/diagrams`. If you have quicklisp installed somewhere else, then please do a `(setf *local-directory* "path/to/your/jeffrey")`, where "path/to/your/jeffrey" should be the directory where the Choiceless Grapher is installed. 

## Detailed description

This program requires package "maxpc", "split-sequence", and "external-program".

**jeffrey.asd** contains the (defsystem ...) command that creates "jeffrey" as a system of packages. The files that comprise jeffrey's packages, their exported functions, and their dependencies are listed in **packages.lisp**.

**graph.lisp** contains the graph structure where the information is stored (the types), and the related functions, which are the basic language of the system. There are two types, one type `node`, which is a name of type natural number, a list of edges of type edge described below, a list of parents of type node, a LaTeX statement of type string, references of type string, and a placeholder for attributes. The other type is `edge`, which is a destination of type node, a relation (T or NIL), which corresponds to positive and negative implication arrow respectively, and a placeholder for attributes. The nodes are to be stored in the exported hash-table `*graph*`.

**parse.lisp** contains parsing functions for reading in node (form) information, and for reading `book1`, the original matrix with all the implication codes. Form information, i.e., name, LaTeX-statement, and references are parsed from the TeX-file `Howard-Rubin-data/FORMSNUM.TEX`. Implication information is parsed simply, because book1 is a simple integer matrix whose lines terminate with -1. I use Max's Parser Combinators ([maxpc](https://github.com/eugeneia/maxpc)).

**process-strings.lisp** contains functions which make the text in any LaTeX-statement LaTeX compatible (the origin is TeX). It's a crude search and replace routine.

**read.lisp** contains the functions that read input, and it can be run in its whole with `(read-all-data)`. This function will first store the form data from `FORMSNUM.TEX` as nodes in `*graph*`, then add edges and parents to these nodes, following only the direct information from `book1`. That is, if book1 has code 1 in position (i,j), then it will add an edge to the node with name i (node i) with destination node j and relation T, and it will add node i to the set of parents of node j. If book1 has code 3 in position (i,j), then it will only add an edge to node i with destination node j and relation NIL. All other codes should be derivable from this information, using the predicates in the next module.

**predicates.lisp** enables the program to ask whether or not a node (form) implies another. The function implies-p only answers positive implication questions, and implies-not-p only answers negative implication questions. In particular, `(implies-p A B)` asks whether A is an ancestor of B and `(implies-not-p B A)` asks whether there is an ancestor B' of B and a descendant A' of A, such that the node B' has an edge with destination A' and relation NIL. Why is the predicate "implies-p" defined like this is clear. For `(implies-not-p B A)`, assume that there is an ancestor B-anc of B and a descendant A-desc of A, such that B-anc does not imply A-desc (the meaning of a NIL-edge from B-anc to A-desc). Then `(implies-not-p B A)` must be T, i.e., B does not imply A, because otherwise we have the implication chain:

  B-anc implies B implies A implies A-desc, 

therefore B-anc implies A-desc, contradiction to the NIL-edge from B-anc to A-desc. 

**test.lisp** contains test data and testing functions, which should be run after every and any change in the above files.
Run all tests while `(in-package :jeffrey-test)` with the command `(test-all)`, which prints a report to your REPL.

**draw.lisp** draws diagrams with the command `(draw '(a b c d ...) "filename" "style")` where `'(a b c d ...)` is a list of natural numbers up to 430, excluding 360, and 423 and 374 for the moment. Requires the database, i.e., `*graph*` to be loaded and `*jeff-matrix*` initiated. Normal users please use the `:jeffrey.main` package.")

**labelmaker.lisp** creates the fancy labels that dot may use. I hope to make this obsolete at some point, and create the labels on the fly.

**main.lisp** the main package is explained above.

**website.lisp** "The currently unfinished website of choiceless grapher, learning sources included at the top of the file. Uses hunchentoot as a webserver, cl-who, maxpc, parenscript, and a local css file, to serve you freshly made diagrams of your *choice*."

**/diagrams/** contains diagrams with sets of forms that make sense, e.g., between forms about alephs and their properties, as well as diagrams with random sets of forms. A boldfaced arrow from A to B means that the implication is non-reversible, i.e., there exists a model of ZF set theory in which B holds and A doesn't. *Just imagine the endless possibilities for random research projects, theses, and papers, filling or boldfacing those arrows! :)*  The `full-diagram.pdf` is also included, only for standard "number names" (not full statements). Its size is 3,41m x 1,72 m. 

**/fancy-labels/** is not included here, but you can produce it from package `:jeffrey.labelmaker` with the command `(make-fancy-labels`).

**/Howard-Rubin-data/** contains the files from the Consequences of the Axiom of Choice Project, which were kindly provided by Prof. Paul Howard. 

**complexity issues**
I have made some small steps to improve the original brute force algorithm for calculating the predicates. The biggest difference was made by memoising with the addition of the `*jeff-matrix*`. A 7%-25% improvement (SBCL and CCL resp.) was achieved by changing the double loop of `(graph-implies-not-p Y X)` to three single loops (finding destinations of nil edges of ancestors of Y, finding descendants of X, and intersecting these two lists).
