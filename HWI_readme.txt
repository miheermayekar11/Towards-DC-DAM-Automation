

# HWI Module - README

The `hwi.py` module facilitates the communication with the lab equipment using TCP/IP. The module consists of several functions that enable setting up connections, sending data and commands, and fetching data from various instruments.

The module is organized as follows:

## I. Setup Commands
This section consists of necessary commands required to be executed before using the library. The following are the import statements for required libraries.
- `pyvisa` - used for controlling GPIB, USB, Serial, and Ethernet instruments
- `time` - used for adding delays between sending commands
- `math` - used for calculating the clock rate
- `matplotlib.pyplot` - used for plotting data
- `types` - used for creating new method types

Additionally, an instance of `visa.ResourceManager()` is created, which is used to create connections with instruments. 

## II. Display Utilities
This section consists of helper functions for displaying output. These functions are:
- `lprint()` - a left-justified print function
- `rprint()` - a right-justified print function
- `lineprint()` - a function for creating a line of equal signs for easy separation of output

## III. Addresses of Equipment
This section consists of functions that return the IP addresses of the equipment. Currently, the module only has addresses for the following equipment:
- Keysight E5071C Network Analyzer
- Tektronix AWG70002A Arbitrary Waveform Generator
- Tektronix DPO70404C Oscilloscope

## IV. Interface Methods
This section consists of functions for sending and fetching data to and from the instruments. The following are the functions:
- `fetch_data_dpo70404c()` - used for fetching data from the oscilloscope
- `send_data_awg70002a()` - used for sending data to the arbitrary waveform generator
- `enable_channel_awg70002a()` - used for enabling the output channel of the arbitrary waveform generator
- `toggle_output_awg70002a()` - used for toggling the output of the arbitrary waveform generator
- `check_awg_rate()` - used for calculating the clock rate and checking if it is below the AWG specifications

## V. Connection Functions
This section consists of functions for connecting to the instruments. The following are the functions:
- `connect_to_awg70002a()` - used for connecting to the arbitrary waveform generator
- `connect_to_dpo70404c()` - used for connecting to the oscilloscope

## VI. Data Parsing Functions
This section currently does not exist in the module.

## VII. Library Test Routine
This section consists of a function that is only executed when the module is run as a program. The function is used to test the connectivity and functionality of the equipment.