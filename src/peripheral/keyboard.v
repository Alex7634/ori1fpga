// Author: AlexG

module keyboard (
  input        clk_i,
  input        rst_i,
  input  [7:0] addr_i,
  output [7:0] data_o,
  output       key_shft_o,
  output       key_ctrl_o,
  output       key_alt_o,
  // PS/2 interface
  input        ps2_clk_i,
  input        ps2_data_i
);


wire [7:0] keyb_data_s;
wire       keyb_valid_s;
reg  [7:0] keys_q [0:7];
reg        key_shft_q;
reg        key_ctrl_q;
reg        key_alt_q;
reg        release_q;
//reg      extended_q;


ps2_intf ps2 (
  .CLK            (clk_i),
  .nRESET         (~rst_i),
  // PS/2 interface (could be bi-dir)
  .PS2_CLK        (ps2_clk_i),
  .PS2_DATA       (ps2_data_i),
  // Byte-wide data interface - only valid for one clock
  // so must be latched externally if required
  .DATA           (keyb_data_s),
  .VALID          (keyb_valid_s),
  .ERROR          ()
);


always @(posedge clk_i or posedge rst_i)
begin
  if (rst_i) begin
    release_q  <= 1'b0;
  //extended_q <= 1'b0;
    keys_q[0]  <= 8'hFF;
    keys_q[1]  <= 8'hFF;
    keys_q[2]  <= 8'hFF;
    keys_q[3]  <= 8'hFF;
    keys_q[4]  <= 8'hFF;
    keys_q[5]  <= 8'hFF;
    keys_q[6]  <= 8'hFF;
    keys_q[7]  <= 8'hFF;
    key_shft_q <= 1'b1;
    key_ctrl_q <= 1'b1;
    key_alt_q  <= 1'b1;
  end
  else begin
    if (keyb_valid_s == 1'b1) begin
      if (keyb_data_s == 8'hF0)
        release_q  <= 1'b1;
    //else if (keyb_data_s == 8'hE0)
    //  extended_q <= 1'b1;
      else begin
        release_q  <= 1'b0;
      //extended_q <= 1'b0;
        case (keyb_data_s)

          8'h01: keys_q[0][0] <= release_q; // F9       (Home)
          8'h09: keys_q[0][1] <= release_q; // F10      (СТР)
          8'h76: keys_q[0][2] <= release_q; // ESC      (АР2)
          8'h05: keys_q[0][3] <= release_q; // F1
          8'h06: keys_q[0][4] <= release_q; // F2
          8'h04: keys_q[0][5] <= release_q; // F3
          8'h0C: keys_q[0][6] <= release_q; // F4
          8'h03: keys_q[0][7] <= release_q; // F5

          8'h0D: keys_q[1][0] <= release_q; // TAB
          8'h0A: keys_q[1][1] <= release_q; // F8       (ПС)
          8'h5A: keys_q[1][2] <= release_q; // ENTER    (ВК)
          8'h66: keys_q[1][3] <= release_q; // BKSP     (ЗБ)
          8'h6B: keys_q[1][4] <= release_q; // Left
          8'h75: keys_q[1][5] <= release_q; // Up
          8'h74: keys_q[1][6] <= release_q; // Right
          8'h72: keys_q[1][7] <= release_q; // Down

          8'h45: keys_q[2][0] <= release_q; // 0
          8'h16: keys_q[2][1] <= release_q; // 1
          8'h1E: keys_q[2][2] <= release_q; // 2
          8'h26: keys_q[2][3] <= release_q; // 3
          8'h25: keys_q[2][4] <= release_q; // 4
          8'h2E: keys_q[2][5] <= release_q; // 5
          8'h36: keys_q[2][6] <= release_q; // 6
          8'h3D: keys_q[2][7] <= release_q; // 7

          8'h3E: keys_q[3][0] <= release_q; // 8
          8'h46: keys_q[3][1] <= release_q; // 9
          8'h4C: keys_q[3][2] <= release_q; // ;
          8'h55: keys_q[3][3] <= release_q; // =
          8'h41: keys_q[3][4] <= release_q; // ,
          8'h4E: keys_q[3][5] <= release_q; // -
          8'h49: keys_q[3][6] <= release_q; // .
          8'h4A: keys_q[3][7] <= release_q; // /

          8'h0E: keys_q[4][0] <= release_q; // `
          8'h1C: keys_q[4][1] <= release_q; // A
          8'h32: keys_q[4][2] <= release_q; // B
          8'h21: keys_q[4][3] <= release_q; // C
          8'h23: keys_q[4][4] <= release_q; // D
          8'h24: keys_q[4][5] <= release_q; // E
          8'h2B: keys_q[4][6] <= release_q; // F
          8'h34: keys_q[4][7] <= release_q; // G

          8'h33: keys_q[5][0] <= release_q; // H
          8'h43: keys_q[5][1] <= release_q; // I
          8'h3B: keys_q[5][2] <= release_q; // J
          8'h42: keys_q[5][3] <= release_q; // K
          8'h4B: keys_q[5][4] <= release_q; // L
          8'h3A: keys_q[5][5] <= release_q; // M
          8'h31: keys_q[5][6] <= release_q; // N
          8'h44: keys_q[5][7] <= release_q; // O
          
          8'h4D: keys_q[6][0] <= release_q; // P
          8'h15: keys_q[6][1] <= release_q; // Q
          8'h2D: keys_q[6][2] <= release_q; // R
          8'h1B: keys_q[6][3] <= release_q; // S
          8'h2C: keys_q[6][4] <= release_q; // T
          8'h3C: keys_q[6][5] <= release_q; // U
          8'h2A: keys_q[6][6] <= release_q; // V
          8'h1D: keys_q[6][7] <= release_q; // W
          
          8'h22: keys_q[7][0] <= release_q; // X
          8'h35: keys_q[7][1] <= release_q; // Y
          8'h1A: keys_q[7][2] <= release_q; // Z
          8'h54: keys_q[7][3] <= release_q; // [
          8'h5D: keys_q[7][4] <= release_q; // \
          8'h5B: keys_q[7][5] <= release_q; // ]
          8'h52: keys_q[7][6] <= release_q; // '
          8'h29: keys_q[7][7] <= release_q; // SPACE

          8'h12: key_shft_q   <= release_q; // L SHFT   (СС)
          8'h59: key_shft_q   <= release_q; // R SHFT   (СС)
          8'h14: key_ctrl_q   <= release_q; // CTRL     (УС)
          8'h11: key_alt_q    <= release_q; // ALT      (РУС/ЛАТ)

          default: ;
        endcase
      end
    end
  end
end

assign data_o = addr_i[0] == 1'b0 ? keys_q[0] :
                addr_i[1] == 1'b0 ? keys_q[1] :
                addr_i[2] == 1'b0 ? keys_q[2] :
                addr_i[3] == 1'b0 ? keys_q[3] :
                addr_i[4] == 1'b0 ? keys_q[4] :
                addr_i[5] == 1'b0 ? keys_q[5] :
                addr_i[6] == 1'b0 ? keys_q[6] :
                addr_i[7] == 1'b0 ? keys_q[7] :
                8'hFF;

assign key_shft_o = key_shft_q;
assign key_ctrl_o = key_ctrl_q;
assign key_alt_o  = key_alt_q;

endmodule
