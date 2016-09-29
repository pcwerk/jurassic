## Description 

These python scripts are to mimic the some behavior of netcat to transfer files between local host and a remote host.
 
pync-in.py listens to a user defined port on the local host, captures data 4096 bytes at a time from input stream and print them onto screen. Users can also save incoming data to a file by using redirection. The connection will terminate when there's no data to read, or terminated by the user. 

pync-out.py takes two arguments. The first argument is the IP address of the remost. The second argument is the port number of the remote host. The script makes the socket connection based on the user defined IP address and port number and send data to output stream. When the transfer is over the socket connection will terminate. 

## Example

To listen on a port and receive data from input stream
* $ ./pync-in.py \<port number\>

To save input data to a file
* $ ./pync-in.py \<port number\> \> \[file name to save transfered data\] 

To send data from current directory to remote host
* $ cat \<file to output\> | ./pync-out.py \<remote host address\> \<port number\>

