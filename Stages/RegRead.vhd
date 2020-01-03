library ieee;
use ieee.std_logic_1164.all;
package RegisterReadPackage is
	component RegisterRead is
		port (
			wr_en, clk, RR_en: in std_logic;
			instr_in, Imm, PC_old_in: in std_logic_vector(15 downto 0);
			from_exe_in, from_ma_in: in std_logic_vector(15 downto 0);
			sel_r1, sel_r2: in std_logic_vector(1 downto 0);
			
			wr_addr: in std_logic_vector(2 downto 0);
			wr_data, PC_wr_data: in std_logic_vector(15 downto 0);
			
			data_out1, data_out2, instr_out, bypass1, bypass2, R0, R1, R2, R3, R4, R5, R6, R7: out std_logic_vector(15 downto 0)
		);
	end component RegisterRead;
end package RegisterReadPackage;



library ieee;
use ieee.std_logic_1164.all;
library work;
use work.Register16Package.all;
use work.RegisterBankPackage.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;	 
use ieee.std_logic_unsigned.all;

entity RegisterRead is
   port (
		wr_en, clk, RR_en: in std_logic;
		instr_in, Imm, PC_old_in: in std_logic_vector(15 downto 0);
		from_exe_in, from_ma_in: in std_logic_vector(15 downto 0);
		sel_r1, sel_r2: in std_logic_vector(1 downto 0);
		
		wr_addr: in std_logic_vector(2 downto 0);
		wr_data, PC_wr_data: in std_logic_vector(15 downto 0);
		
		data_out1, data_out2, instr_out, bypass1, bypass2, R0, R1, R2, R3, R4, R5, R6, R7: out std_logic_vector(15 downto 0)
	);
end entity RegisterRead;





architecture Struct of RegisterRead is
	
	signal temp_rb_out1, temp_rb_out2, sig_rr_data1, sig_rr_data2: std_logic_vector(15 downto 0);
	signal sig_out1, sig_out2, sig_instr_out, sig_bypass1, sig_bypass2: std_logic_vector(15 downto 0);
	signal sig_rd_addr1, sig_rd_addr2: std_logic_vector(2 downto 0);
	begin
		
		sig_instr_out(15 downto 12) <= instr_in(15 downto 12); -- opcode
--		sig_instr_out(11 downto 9) <= 								-- dest
		sig_instr_out(8 downto 2) <= "0000000";
		sig_instr_out(1 downto 0) <= instr_in(1 downto 0);    --CZ

		RB: RegisterBank port map(
			wr_en=>wr_en, clk=>clk, wr_addr=>wr_addr, 
			rd_addr1=>sig_rd_addr1, rd_addr2=>sig_rd_addr2, 
			wr_data=>wr_data,
			data_out1=>temp_rb_out1, data_out2=>temp_rb_out2,
			PC_wr_data => PC_wr_data,
			R0 => R0, R1 => R1, R2 => R2, R3 => R3, R4 => R4, R5 => R5, R6 => R6, R7 => R7
		);
					
		RR_EX1: Register16 port map(d=>sig_out1, clk=>clk, en=>RR_en, o=>data_out1);
		RR_EX2: Register16 port map(d=>sig_out2, clk=>clk, en=>RR_en, o=>data_out2);
		RR_EX3: Register16 port map(d=>sig_instr_out, clk=>clk, en=>RR_en, o=>instr_out);  -- opcode-4 dest-3 7-0 C-1 Z-1 
		RR_EX4: Register16 port map(d=>sig_bypass1, clk=>clk, en=>RR_en, o=>bypass1);
		RR_EX5: Register16 port map(d=>sig_bypass2, clk=>clk, en=>RR_en, o=>bypass2);
		
		-- addr for read data 1
		with instr_in(15 downto 12) select
			sig_rd_addr1 <= instr_in(11 downto 9) when "0000", -- RA
								instr_in(11 downto 9) when "0001", -- RA
								instr_in(11 downto 9) when "0010", -- RA
								instr_in(8 downto 6) when "0100", -- RB
								instr_in(11 downto 9) when "0101", -- RA
								-- instr_in(8 downto 6) when "0110", -- RA
								-- instr_in(11 downto 9) when "0111", -- RA
								instr_in(11 downto 9) when "1100", -- RA
								instr_in(8 downto 6) when "1001", -- RB
								"000" when others;
		-- addr for read data 1					
		with instr_in(15 downto 12) select
			sig_rd_addr2 <= instr_in(8 downto 6) when "0000", -- RB
								 instr_in(8 downto 6) when "0010", -- RB
								 instr_in(8 downto 6) when "0101", -- RB
								--  instr_in(8 downto 6) when "0111", -- R
								 instr_in(8 downto 6) when "1100", -- RB
								 "000" when others;
		
		
		with sel_r1 select
			sig_rr_data1 <= temp_rb_out1 when "00",
							from_exe_in when "10",
							from_ma_in when "01",
							x"0000" when others;

		with sel_r2 select
			sig_rr_data2 <= temp_rb_out2 when "00",
							from_exe_in when "10",
							from_ma_in when "01",
							x"0000" when others;


		-- select for alu operand 1
		with instr_in(15 downto 12) select
			sig_out1 <= sig_rr_data1 when "0000", -- RA
						sig_rr_data1 when "0001", -- RA
						sig_rr_data1 when "0010", -- RA
						sig_rr_data1 when "0100", -- RB
						sig_rr_data2 when "0101", -- RB
						-- sig_rr_data1 when "0110", -- RA
						-- sig_rr_data1 when "0111", -- RA
						PC_old_in when "1100", -- PC
						PC_old_in when "1000", -- PC
						x"0000" when others;
		
		-- select for alu operand 2
		with instr_in(15 downto 12) select
			sig_out2 <= sig_rr_data2 when "0000", -- RB
						Imm when "0001", -- Imm
						sig_rr_data2 when "0010", -- RA
						Imm when "0100", -- Imm
						Imm when "0101", -- Imm
						-- Imm when "0110", -- Imm
						-- Imm when "0111", -- Imm
						Imm when "1100", -- Imm
						Imm when "1000", -- Imm
						x"0000" when others;												
		
		
		
		with instr_in(15 downto 12) select
			sig_bypass1 <=  Imm when "0011",
							sig_rr_data1 when "0101", -- RA
							-- sig_rr_data2 when "0111", -- R
							sig_rr_data1 when "1100", -- RA
							PC_old_in when "1000", -- PC
							sig_rr_data1 when "1001", -- RB
							"0000000000000000" when others;
		

		with instr_in(15 downto 12) select
			sig_bypass2 <=  sig_rr_data2 when "1100", -- RB
							PC_old_in when "1001", -- PC
							"0000000000000000" when others;
		
		
		
		with instr_in(15 downto 12) select	-- dest
			sig_instr_out(11 downto 9) <= 
					instr_in(5 downto 3) when "0000", -- RC
					instr_in(8 downto 6) when "0001", -- RB
					instr_in(5 downto 3) when "0010", -- RC
					instr_in(11 downto 9) when "0011", -- RA
					instr_in(11 downto 9) when "0100", -- RA
					-- instr_in(8 downto 6) when "0110", 
					-- instr_in(8 downto 6) when "0111",
					instr_in(11 downto 9) when "1000", -- RA
					instr_in(11 downto 9) when "1001", -- RA
					"000" when others;
				
end Struct;


