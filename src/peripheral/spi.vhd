-------------------------------------------------------------------------------
--
-- MSX1 FPGA project
--
-- Copyright (c) 2016, Fabio Belavenuto (belavenuto@gmail.com)
--
-- All rights reserved
--
-- Redistribution and use in source and synthezised forms, with or without
-- modification, are permitted provided that the following conditions are met:
--
-- Redistributions of source code must retain the above copyright notice,
-- this list of conditions and the following disclaimer.
--
-- Redistributions in synthesized form must reproduce the above copyright
-- notice, this list of conditions and the following disclaimer in the
-- documentation and/or other materials provided with the distribution.
--
-- Neither the name of the author nor the names of other contributors may
-- be used to endorse or promote products derived from this software without
-- specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
-- THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
-- PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
-- CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
-- SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
-- ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-- POSSIBILITY OF SUCH DAMAGE.
--
-- Please report bugs to the author, but before you do so, please
-- make sure that this is not a derivative work and that
-- you have the latest version of this file.
--
-------------------------------------------------------------------------------
---
--- SPI ports:
--- 0 - Control
--- 1 - Data
---

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi is
  port (
    clock_i     : in    std_logic;
    reset_i     : in    std_logic;
    addr_i      : in    std_logic;
    cs_i        : in    std_logic;
    wr_i        : in    std_logic;
    rd_i        : in    std_logic;
    data_i      : in    std_logic_vector(7 downto 0);
    data_o      : out   std_logic_vector(7 downto 0);
    has_data_o  : out   std_logic;
    -- SD card interface
    spi_cs_n_o  : out   std_logic_vector(2 downto 0)  := "111";
    spi_sclk_o  : out   std_logic;
    spi_mosi_o  : out   std_logic;
    spi_miso_i  : in    std_logic;
    sd_wp_i     : in    std_logic;
    sd_pres_n_i : in    std_logic
  );
end entity;

architecture rtl of spi is

  signal sck_delayed_s  : std_logic;
  signal counter_s      : unsigned(3 downto 0);
  -- Shift register has an extra bit because we write on the
  -- falling edge and read on the rising edge
  signal shift_r        : std_logic_vector(8 downto 0);
  signal port0_r        : std_logic_vector(7 downto 0);
  signal port1_r        : std_logic_vector(7 downto 0);
  signal enable_s       : std_logic;
  signal sd_chg_s       : std_logic;
  signal sd_chg_q       : std_logic;
  signal spi_ctrl_rd_s  : std_logic;

begin

  enable_s      <= '1' when cs_i = '1' and (wr_i = '1' or rd_i = '1')  else '0';

  spi_ctrl_rd_s <= '1' when enable_s = '1' and addr_i = '0' and rd_i = '1'  else '0';

  -- Port reading
  has_data_o  <= '1'  when enable_s = '1' and rd_i = '1'  else  
                 '0';
  data_o      <= port0_r when spi_ctrl_rd_s = '1'                            else
                 port1_r when enable_s = '1' and addr_i = '1' and rd_i = '1' else
                 (others => '1');

  port0_r <= "00000" & sd_wp_i & sd_pres_n_i & sd_chg_s;

  -- Disk change
  process (reset_i, spi_ctrl_rd_s, sd_pres_n_i)
  begin
    if reset_i = '1' then
      sd_chg_q <= '0';
    elsif sd_pres_n_i = '1' then
      sd_chg_q <= '1';
    elsif falling_edge(spi_ctrl_rd_s) then
      sd_chg_q <= '0';
    end if;
  end process;

  process (reset_i, spi_ctrl_rd_s)
  begin
    if reset_i = '1' then
      sd_chg_s <= '0';
    elsif rising_edge(spi_ctrl_rd_s) then
      sd_chg_s <= sd_chg_q;
    end if;
  end process;

  --------------------------------------------------
  -- Essa parte lida com a porta SPI por hardware --
  --      Implementa um SPI Master Mode 0         --
  --------------------------------------------------

  process(clock_i, reset_i)
  begin
    if reset_i = '1' then
      spi_cs_n_o <= "111";
    elsif rising_edge(clock_i) then
      if enable_s = '1' and addr_i = '0' and wr_i = '1'  then
        spi_cs_n_o(2) <= data_i(7);
        spi_cs_n_o(1) <= data_i(1);
        spi_cs_n_o(0) <= data_i(0);
      end if;
    end if;
  end process;

  -- SD card outputs from clock divider and shift register
  spi_sclk_o  <= sck_delayed_s;
  spi_mosi_o  <= shift_r(8);

  -- Atrasa SCK para dar tempo do bit mais significativo mudar de estado e acertar MOSI antes do SCK
  process (clock_i, reset_i)
  begin
    if reset_i = '1' then
      sck_delayed_s <= '0';
    elsif rising_edge(clock_i) then
      sck_delayed_s <= not counter_s(0);
    end if;
  end process;

  -- SPI write
  process(clock_i, reset_i)
  begin   
    if reset_i = '1' then
      shift_r   <= (others => '1');
      port1_r   <= (others => '1');
      counter_s <= "1111"; -- Idle
    elsif rising_edge(clock_i) then
      if counter_s = "1111" then
        port1_r     <= shift_r(7 downto 0); -- Store previous shift register value in input register
        shift_r(8)  <= '1';                 -- MOSI repousa em '1'

        -- Idle - check for a bus access
        if enable_s = '1' and addr_i = '1'  then
          -- Write loads shift register with data
          -- Read loads it with all 1s
          if rd_i = '1' then
            shift_r <= (others => '1');               -- Uma leitura seta 0xFF para enviar e dispara a transmissão
          else
            shift_r <= data_i & '1';                  -- Uma escrita seta o valor a enviar e dispara a transmissão
          end if;
          counter_s <= "0000"; -- Initiates transfer
        end if;
      else
        counter_s <= counter_s + 1;                   -- Transfer in progress

        if sck_delayed_s = '0' then
          shift_r(0)  <= spi_miso_i;                  -- Input next bit on rising edge
        else
          shift_r     <= shift_r(7 downto 0) & '1';     -- Output next bit on falling edge
        end if;
      end if;
    end if;
  end process;
end architecture;
