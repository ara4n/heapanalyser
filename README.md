### A trivial V8 heap dump analyser

This is a collection of quick and dirty experiments in parsing heap dumps
provided by Chrome Dev Tools when you hit 'Save' on a heap dump.

The goals here are:
 * Handle massive heap dumps (>2GB) such as those you can get from badly
   behaving webapps like an overloaded [riot/web](https://github.com/vector-im/riot-web).
 * Provide cheap & cheerful programmatic access to basic heap statistics
   in order to see what number & what type of objects are present -
   particularly as the pie charts and summaries from Chrome Dev Tools
   itself don't always seem to add up correctly.
 
Originally this was a simple wrapper around the `heapsnapshot` npm
package, albeit using `JSONStream` to load the massive JSON heap files
without running into node's string size limits (~1GB on 64-bit;
~250GB on 32-bit).  Unfortunately this still runs out of heap, perhaps
due to `heapsnapshot` itself not being designed for massive heaps.

So instead there's a perl script called `heap-analyser.pl` which naively
parses a snapshots and prints out common aggregate stats instead.  It doesn't
currently parse edge data, so can't be used to model the retainers or
dominators graph for the heap.

The end result is less ambiguous pie charts:

![pie charts](https://matrix.org/_matrix/media/v1/download/matrix.org/hUeblVvNRLrNGwRxFmRZkFhW)

...and stuff like this:

![interning](https://matrix.org/_matrix/media/v1/download/matrix.org/KYnCpIFhTaggxCCLNYCQAmev)

The node app could probably be made to work by making `JSONStream` emit the
nodes, edges & strings elements more incrementally rather than trying to emit
a single JSON structure in one fell swoop - unless `heapsnapshot` then ends up
being the bottleneck.
