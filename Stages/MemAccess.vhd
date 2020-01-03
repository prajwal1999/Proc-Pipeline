library ieee;
use ieee.std_logic_1164.all;
package MemoryAccessPackage is

	component MemoryAccess is
		port ( 
			MA_en, wr_en, clk: in std_logic;
			instr_in, data_in1, data_in2: in std_logic_vector(15 downto 0);
			instr_out, out1, out2: out std_logic_vector(15 downto 0)
		);
	end component MemoryAccess;
	
end package MemoryAccessPackage;



library ieee;
use ieee.std_logic_1164.all;
library work;
use work.RAMPackage.all;
use work.Register16Package.all;

entity MemoryAccess is
   port ( 
		MA_en, wr_en, clk: in std_logic;
		instr_in, data_in1, data_in2: in std_logic_vector(15 downto 0);
		instr_out, out1, out2: out std_logic_vector(15 downto 0)
	);
end entity MemoryAccess;

architecture Struct of MemoryAccess is
	signal ram_rd_addr, ram_data, sig_out1, sig_out2, sig_wr_addr, sig_wr_data: std_logic_vector(15 downto 0);
--	signal load_multiple: std_logic;
	begin
	
  
	with instr_in(15 downto 12) select
		ram_rd_addr <= 	data_in1 when "0100",
						-- data_in1 when "0110",
						x"0000" when others;


	with instr_in(15 downto 12) select
		sig_wr_addr <= 	data_in1 when "0101",
						-- data_in1 when "0111",
						x"0000" when others;

	with instr_in(15 downto 12) select
		sig_wr_data <= 	data_in2 when "0101",
						-- data_in2 when "0111",
						x"0000" when others;


	ram1: RAM port map (wr_en=>wr_en, clk=>clk, rd_addr=>ram_rd_addr, wr_addr=>sig_wr_addr,
							  wr_data=>sig_wr_data, rd_data=>ram_data);
	
	MA_WB1: Register16 port map(d=>instr_in, clk=>clk, en=>MA_en, o=>instr_out);	-- opcode-4 dest-3 bypass_equal 4-0 cin zin  C-1 Z-1 
	MA_WB2: Register16 port map(d=>sig_out1, clk=>clk, en=>MA_en, o=>out1);
	MA_WB3: Register16 port map(d=>sig_out2, clk=>clk, en=>MA_en, o=>out2);


							
	with instr_in(15 downto 12) select
		sig_out1 <= data_in1 when "0000", -- RA+RB
					data_in1 when "0001", -- RA+Imm
					data_in1 when "0010", -- RA+RB
					data_in1 when "0011", -- 9bit Imm
					ram_data when "0100",
					-- ram_data when "0110",
					data_in2 when "1000", -- PC_old
					data_in2 when "1001", -- PC_old
					x"0000" when others;
						
			
	with instr_in(15 downto 12) select
		sig_out2 <= data_in1 when "1100", -- PC+Imm
					data_in1 when "1000", -- PC+Imm
					data_in1 when "1001", -- RB
					x"0000" when others;
						
end Struct;
