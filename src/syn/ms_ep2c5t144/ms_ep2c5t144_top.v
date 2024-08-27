// Author: AlexG

module ms_ep2c5t144_top (
  // Devboard
  input         CLK50M,
  input         nKEY,   // key
  output        nLED0,  // D2
  output        nLED1,  // D4
  output        nLED2,  // D5

  // UART
//input         UART1_RXD,
//output        UART1_TXD,
//output        UART1_RTS,
  
  // PS2
  input         PS2_CLK,
  input         PS2_DATA,
  
  // VIDEO
  output        VIDEO_HS,
  output        VIDEO_VS,
  output [1:0]  VIDEO_R,
  output [1:0]  VIDEO_G,
  output [1:0]  VIDEO_B,
  
  // SRAM (512kB 524.288 words × 8 bits)
  inout  [ 7:0] SRAM_IO,
  output [18:0] SRAM_A,
  output        SRAM_nWE,
  output        SRAM_nOE,
  output        SRAM_nCS,
  
  // SD Card
  output        SD_SCLK,
  output        SD_MOSI,
  input         SD_MISO,
  output        SD_CS
);

  // de-activate unused SRAM
//assign SRAM_nCS   = 1'b 1;

  // de-activate unused outputs
//assign nLED0      = 1'b 1;
  assign nLED1      = 1'b 1;
//assign nLED2      = 1'b 1;

  // Clocks
  wire        clk_master_s;
  wire        clk_mem_s;

  // Resets
  wire        pll_locked_s;
  wire        rst_s;
  wire        por_s;

  // MONITOR
  wire [10:0] monitor_addr_s;
  wire [ 7:0] monitor_data_s;

  // ROM disk
  wire [15:0] romdsk_addr_s;
  wire [ 7:0] romdsk_data_s;

  // RAM
  wire [17:0] ram_addr_s;
  wire [15:0] ram_data_di_s;
  wire [ 7:0] ram_data_do_s;
  wire        ram_we_s;
  wire        ram_oe_s;
  wire        ram_ce_s;
  wire        ram_ldata_we_s;
  wire        ram_udata_we_s;

  // VIDEO
  wire [ 3:0] rgb_r_s;
  wire [ 3:0] rgb_g_s;
  wire [ 3:0] rgb_b_s;

  // PLL
  pll1 pll (
    .inclk0         (CLK50M),         // 50.000 MHz
    .c0             (clk_master_s),   // 20.000 MHz
    .c1             (clk_mem_s),      // 20.000 MHz
    .locked         (pll_locked_s)
  );

  // MONITOR
  m2 monitor ( // 2kb
    .clk            (clk_master_s),
    .addr           (monitor_addr_s),
    .data           (monitor_data_s)
  );

  // ROM disk
  rom_sdos romdsk ( // 8kb
    .clk            (clk_master_s),
    .addr           (romdsk_addr_s[12:0]),
    .data           (romdsk_data_s)
  );

  dpSRAM_5128 ram (
    .clk_i          (clk_mem_s),
    // Port 0
    .porta0_addr_i  ({1'b0, ram_addr_s[17:1], 1'b0}), // 256kb (max 512kb)
    .porta0_ce_i    (ram_ce_s),
    .porta0_oe_i    (ram_oe_s),
    .porta0_we_i    (ram_ldata_we_s),
    .porta0_data_i  (ram_data_do_s),
    .porta0_data_o  (ram_data_di_s[ 7:0]),
    // Port 1
    .porta1_addr_i  ({1'b0, ram_addr_s[17:1], 1'b1}), // 256kb (max 512kb)
    .porta1_ce_i    (ram_ce_s),
    .porta1_oe_i    (ram_oe_s),
    .porta1_we_i    (ram_udata_we_s),
    .porta1_data_i  (ram_data_do_s),
    .porta1_data_o  (ram_data_di_s[15:8]),
    // SRAM in board
    .sram_addr_o    (SRAM_A),
    .sram_data_io   (SRAM_IO),
    .sram_ce_n_o    (SRAM_nCS),
    .sram_oe_n_o    (SRAM_nOE),
    .sram_we_n_o    (SRAM_nWE)
  );
  assign ram_ldata_we_s = ~ram_addr_s[0] & ram_we_s;
  assign ram_udata_we_s =  ram_addr_s[0] & ram_we_s;

  // The Orion 128
  orion the_orion (
    .clk_i          (clk_master_s),
    .por_i          (por_s),
    .rst_i          (rst_s),
    // IPL
  //.iplrom_addr_o  (iplrom_addr_s),
  //.iplrom_data_i  (iplrom_data_s),
    // MONITOR
    .monitor_addr_o (monitor_addr_s),
    .monitor_data_i (monitor_data_s),
    // ROM disk
    .romdsk_addr_o  (romdsk_addr_s),
    .romdsk_data_i  (romdsk_data_s),
    // RAM
    .ram_addr_o     (ram_addr_s),
    .ram_data_di_i  (ram_data_di_s),
    .ram_data_do_o  (ram_data_do_s),
    .ram_we_o       (ram_we_s),
    .ram_oe_o       (ram_oe_s),
    .ram_ce_o       (ram_ce_s),
    // PS2
    .ps2_clk_i      (PS2_CLK),
    .ps2_data_i     (PS2_DATA),
    // SD CARD
    .spi_cs_n_o     (SD_CS),
    .spi_sclk_o     (SD_SCLK),
    .spi_mosi_o     (SD_MOSI),
    .spi_miso_i     (SD_MISO),
    // RGB
    .hsync_n_o      (VIDEO_HS),
    .vsync_n_o      (VIDEO_VS),
    .rgb_r_o        (rgb_r_s),
    .rgb_g_o        (rgb_g_s),
    .rgb_b_o        (rgb_b_s),
    // AUDIO
    .beep_o         (),
    // LEDS
    .led0_n_o       (nLED0),
    .led1_n_o       (nLED2)
  );
  assign VIDEO_R = {rgb_r_s[3], rgb_r_s[1]};
  assign VIDEO_G = {rgb_g_s[3], rgb_g_s[1]};
  assign VIDEO_B = {rgb_b_s[3], rgb_b_s[1]};

  // Power-on reset
  reg [7:0] cnt_por_q;
  wire por_async_s = ~pll_locked_s; 
  always @(posedge clk_master_s or posedge por_async_s)
  begin
    if (por_async_s)
      cnt_por_q <= 8'h00;
    else if (cnt_por_q != 8'hFF)
      cnt_por_q <= cnt_por_q + 8'h01;
  end
  assign por_s = ~(cnt_por_q == 8'hFF);

  // Reset
  reg [7:0] cnt_rst_q;
  wire rst_async_s = por_s | ~nKEY; // key
  always @(posedge clk_master_s or posedge rst_async_s)
  begin
    if (rst_async_s)
      cnt_rst_q <= 8'h00;
    else if (cnt_rst_q != 8'hFF)
      cnt_rst_q <= cnt_rst_q + 8'h01;
  end
  assign rst_s = ~(cnt_rst_q == 8'hFF);

endmodule
