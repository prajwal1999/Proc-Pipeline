library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package ControllerPackage is
	component Controller is
		port (
			clk, reset: in std_logic;
			zin, cin: in std_logic;
			
			-- fetch controls
			fetch_instr: in std_logic_vector(15 downto 0); -- fetch se aane wali instr
			fetch_en: out std_logic;
			
			-- decoder controls
			decode_instr: in std_logic_vector(15 downto 0); -- decode se aane wali instr
			decode_en: out std_logic;
			
			-- register read controls
			rr_instr: in std_logic_vector(15 downto 0); -- rr se aane wali instr
			rr_en, rr_wr_en: out std_logic;
			rr_sel_r1, rr_sel_r2: out std_logic_vector(1 downto 0);
			
			-- execute controls
			exe_instr: in std_logic_vector(15 downto 0); -- exe se aane wali instr
			exe_en: out std_logic;
	
--			-- memory access controls
			ma_instr: in std_logic_vector(15 downto 0); -- ma se aane wali instr
			ma_en, ma_wr_en: out std_logic;
	
			--write back controls
			wb_instr: in std_logic_vector(15 downto 0); -- wb se aane wali instr
			wb_en: out std_logic;
	
			-- zero carry
			zout, cout : out std_logic
	  );
	end component Controller;
end package ControllerPackage;

library std;
use std.standard.all;
library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;	 
use ieee.std_logic_unsigned.all;

use work.Blocks.all;

entity Controller is 
	port (
		clk, reset: in std_logic;
		zin, cin: in std_logic;
		
		-- fetch controls
		fetch_instr: in std_logic_vector(15 downto 0); -- fetch se aane wali instr
		fetch_en: out std_logic;
		
		-- decoder controls
		decode_instr: in std_logic_vector(15 downto 0); -- decode se aane wali instr
		decode_en: out std_logic;
		
		-- register read controls
		rr_instr: in std_logic_vector(15 downto 0); -- rr se aane wali instr
		rr_en, rr_wr_en: out std_logic;
		rr_sel_r1, rr_sel_r2: out std_logic_vector(1 downto 0);
		
		-- execute controls
		exe_instr: in std_logic_vector(15 downto 0); -- exe se aane wali instr
		exe_en: out std_logic;

--			-- memory access controls
		ma_instr: in std_logic_vector(15 downto 0); -- ma se aane wali instr
		ma_en, ma_wr_en: out std_logic;

		--write back controls
		wb_instr: in std_logic_vector(15 downto 0); -- wb se aane wali instr
		wb_en: out std_logic;

		-- zero carry
		zout, cout : out std_logic
		);
end entity;

architecture Struct of Controller is
		-- signals
		signal destInFetch: std_logic_vector(2 downto 0);
		begin
		

		with fetch_instr(15 downto 12) select
				destInFetch <=
					fetch_instr(5 downto 3) when "0000",
					fetch_instr(5 downto 3) when "0010",
					fetch_instr(8 downto 6) when "0001",
					fetch_instr(11 downto 9) when "0011",
					fetch_instr(11 downto 9) when "0100",
					null when others;
			
		
		fetch_en <= '1';
		decode_en <= '1';
		rr_en <= '1';
		rr_wr_en <= '1';
		rr_sel_r1 <= "00";
		rr_sel_r2 <= "00";
		exe_en <= '1';
		ma_en <= '1';
		ma_wr_en <= '1';
		wb_en <= '1';
		zout <= '0';
		cout <= '0';
		
		--		fetch control:
		process(clk)
			variable var_fetch_en : std_logic;
			
			begin
--			var_fetch_en := '1';
--			
--			if(fetch_instr(15 downto 14)="11" or fetch_instr(15 downto 14)="10" or fetch_instr(14 downto 13)="11") then
--				var_fetch_en := '0';
--			else
--				var_fetch_en := '1';
--			end if;
--			
--			if(falling_edge(clk)) then
--				fetch_en <= var_fetch_en;
--			end if;
		

		end process;
		
		
end Struct;
