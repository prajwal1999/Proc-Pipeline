library ieee;
use ieee.std_logic_1164.all;

package EXstagePackage is
	component EXstage is
		port (
			clk, exe_en, cin, zin: in std_logic;
			data_in1, data_in2, instr_in, bypass1_in, bypass2_in: in std_logic_vector(15 downto 0);
			
			instr_out, data_out1, data_out2: out std_logic_vector(15 downto 0);
			cout,zout: out std_logic
		);
	end component EXstage;
end package EXstagePackage;



library ieee;
use ieee.std_logic_1164.all;
library work;
use work.gates.all;
use work.Register16Package.all;
use work.ALU_16Package.all;

entity EXstage is
	port(
		clk, exe_en, cin, zin: in std_logic;
		data_in1, data_in2, instr_in, bypass1_in, bypass2_in: in std_logic_vector(15 downto 0);
		
		instr_out, data_out1, data_out2: out std_logic_vector(15 downto 0);
		cout,zout: out std_logic
	);
end entity;

architecture behaviour of EXstage is

	--define signals here
	signal temp_alu_result, sig_instr, sig_data1, sig_data2: std_logic_vector(15 downto 0);
	signal alu_op: std_logic_vector(1 downto 0);
	signal is_bypass_equal, sig_C, sig_Z: std_logic;
	signal CZ_add_nand: std_logic_vector(7 downto 0);  --(instr-4 C Z cin zin)
	signal xor_check: std_logic_vector(15 downto 0);
	begin

	CZ_add_nand(7 downto 4) <= instr_in(15 downto 12);
	CZ_add_nand(3 downto 2) <= instr_in(1 downto 0);
	CZ_add_nand(1) <= cin;
	CZ_add_nand(0) <= zin;
	
	ALU1: ALU_16 port map(ALU_OP => alu_op, A=> data_in1, B=> data_in2, cin=> cin, zin=> zin, alu_en => exe_en, S=> temp_alu_result, C=> sig_C, Z=> sig_Z);
	
	EX_MA1: register16 port map(d => sig_data1, clk => clk, en => exe_en, o =>data_out1);
	EX_MA2: register16 port map(d => sig_instr, clk => clk, en => exe_en, o =>instr_out);	 -- opcode-4 dest-3 bypass_equal 4-0 cin zin  C-1 Z-1 
	EX_MA3: register16 port map(d => sig_data2, clk => clk, en => exe_en, o =>data_out2);

 
	with instr_in(15 downto 12) select
		alu_op <= "00" when "0000",
				 "00" when "0001",
				 "01" when "0010",
				 "00" when "0100",
				 "00" when "0101",
				 "00" when "1100",
				 "00" when "1000",
				 "11" when others;
	 
	xor_check <= bypass1_in xor bypass2_in;
	with xor_check select
		is_bypass_equal <= '1' when "0000000000000000",
								 '0' when others;
		
	sig_instr(15 downto 9) <= instr_in(15 downto 9);
	sig_instr(8) <= is_bypass_equal;
	sig_instr(7 downto 4) <= instr_in(7 downto 4);
	sig_instr(3) <= cin;
	sig_instr(2) <= zin;
	sig_instr(1 downto 0) <= instr_in(1 downto 0);

	
	with instr_in(15 downto 12) select
		sig_data1 <= temp_alu_result when "0000", -- RA+RB
					temp_alu_result when "0001", -- RA+Imm
					temp_alu_result when "0010", -- RA+RB
					bypass1_in when "0011", -- 9bit Imm
					temp_alu_result when "0100", -- RB+Imm
					temp_alu_result when "0101", -- RB+Imm
					-- temp_alu_result when "0110",
					-- temp_alu_result when "0111",
					temp_alu_result when "1100", -- PC+Imm
					temp_alu_result when "1000", -- PC+Imm
					bypass1_in when "1001", -- RB
					x"0000" when others;

	with instr_in(15 downto 12) select
		sig_data2 <= bypass1_in when "0101", -- RA
					-- bypass1_in when "0111",
					bypass1_in when "1000", -- PC_old
					bypass2_in when "1001", -- PC_old
					x"0000" when others;
	
	
	
	
	
	with CZ_add_nand select
		cout <= cin when "00001000",
			  cin when "00001001",
			  cin when "00000100",
			  cin when "00000110",
			  cin when "00101000",
			  cin when "00101001",
			  cin when "00100100",
			  cin when "00100110",
			  sig_C when others;
			  
	with CZ_add_nand select
		zout <= zin when "00001000",
			  zin when "00001001",
			  zin when "00000100",
			  zin when "00000110",
			  zin when "00101000",
			  zin when "00101001",
			  zin when "00100100",
			  zin when "00100110",
			  sig_Z when others;
			  

 
 end behaviour;
 
 