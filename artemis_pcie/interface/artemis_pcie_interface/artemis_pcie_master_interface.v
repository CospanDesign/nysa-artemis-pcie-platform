/*
Distributed under the MIT licesnse.
Copyright (c) 2011 Dave McCoy (dave.mccoy@cospandesign.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of
this start_of_frametware and associated documentation files (the "Software"), 
to deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is furnished
to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

//ft_master_interface.v

/*
 * Change log
 * 10/23/2013
 *  -Fixed a bug in the response where the full response is always sent even
 *  when a Ping was returned
 *  -Added interrupts to the full 13 charater response type
 *
 */

`timescale 1ns/1ps

`include "cbuilder_defines.v"

`define PING_RESP         ((~`COMMAND_PING)         & (4'hF))
`define WRITE_RESP        ((~`COMMAND_WRITE)        & (4'hF))
`define READ_RESP         ((~`COMMAND_READ)         & (4'hF))
`define RESET_RESP        ((~`COMMAND_RESET)        & (4'hF))
`define MASTER_ADDR_RESP  ((~`COMMAND_MASTER_ADDR)  & (4'hF))
`define CORE_DUMP_RESP    ((~`COMMAND_CORE_DUMP)    & (4'hF))

module artemis_pcie_master_interface (
  //boilerplate
  input               rst,
  input               clk,

  //master interface
  input               i_master_ready,
  output              o_ih_reset,
  output reg          o_ih_ready,

  output  reg [31:0]  o_in_command,
  output  reg [31:0]  o_in_address,
  output  reg [31:0]  o_in_data,
  output  reg [27:0]  o_in_data_count,

  output  reg         o_oh_ready,
  input               i_oh_en,

  input   [31:0]      i_out_status,
  input   [31:0]      i_out_address,
  input   [31:0]      i_out_data,
  input   [27:0]      i_out_data_count

  //PCIE Interface
  //debug
);
//Local Parameters
//Registers/Wires
//Submodules
//Asynchronous Logic
//Synchronous Logic

endmodule
