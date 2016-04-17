This Playground demonstrates a very simple system for interacting with Signals, as you might do in a Reactive Programming environment.

The playground implements many common Signal operations, including:
  - `map`: transforms a Signal of one type into a Signal of another
  - `filter`: produces a Signal only for values passing some predicated
  - `reduce`: produces a Signal whose values indicate some running process (e.g. summing elements, etc)
  - `map2`: produces a Signal whose values are those of two other Signals combined in some way
  - Logical-`and`: combines two Bool Signals with &&
  - Logical-`or`: combines two Bool Signals with ||
  - Logical-`xor`: combines two Bool Signals with xor
  - Cartesian `product`: produces a Signal whose values are the tuple of the latest values from two Signals
  - `sum`: produces a Signal whose values are an Either of the two source Signal types.
  - `throttle`: produces a Signal that only emits the most recent value, and doesn't emit more frequently than the specified interval
