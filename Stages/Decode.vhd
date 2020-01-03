library ieee;
use ieee.std_logic_1164.all;
package DecoderPackage is
	component Decoder is
		port (
			decode_en, clk: in std_logic;
			instr_in, PC_old_in: in std_logic_vector(15 downto 0);
			instr_out, Imm, PC_old_out: out std_logic_vector(15 downto 0)
		);
	end component Decoder;
end package DecoderPackage;


library ieee;
use ieee.std_logic_1164.all;
library work;
use work.Register16Package.all;
use work.Blocks.all;

entity Decoder is 	
	port(
		decode_en, clk: in std_logic;
		instr_in, PC_old_in: in std_logic_vector(15 downto 0);
		instr_out, Imm, PC_old_out: out std_logic_vector(15 downto 0)
	);
end Decoder;

architecture Struct of Decoder is
		signal sig_instr, imm6bit, imm9bit, sig_Imm, msb_imm: std_logic_vector(15 downto 0);
		signal lm_sm_imm: std_logic_vector(7 downto 0);
		signal lm_sm_addr: std_logic_vector(2 downto 0);
		signal offset, new_offset: std_logic_vector(15 downto 0);
		signal lm_sm_complete: std_logic;
	begin 		
			
		imm6bit(5 downto 0) <= instr_in(5 downto 0);
		imm6bit(15 downto 6) <= "0000000000";
		imm9bit(8 downto 0) <= instr_in(8 downto 0);
		imm9bit(15 downto 9) <= "0000000";
		msb_imm(15 downto 7) <= instr_in(8 downto 0);
		msb_imm(6 downto 0) <= "0000000";

		sig_instr <= instr_in;
		-- sig_instr(15 downto 9) <= instr_in(15 downto 9);
		-- sig_instr(5 downto 1) <= instr_in(5 downto 1);
		-- sig_instr(8 downto 6) <= lm_sm_addr when instr_in(15 downto 12) = "0110" else
		-- 									 instr_in(8 downto 6);
						
		-- sig_instr(0) <= lm_sm_complete when instr_in(15 downto 12) = "0110" else
		-- 				instr_in(0);
		
		with instr_in(15 downto 12) select 
			sig_Imm <= imm6bit when "0001",
						  msb_imm when "0011",
						  imm6bit when "0100",
						  imm6bit when "0101",
						  imm6bit when "1100",
						  imm9bit when "1000",
						--   offset when "0110",
						  "0000000000000000" when others;
				
--	plus1: Plus2Adder port map(A=>offset, S=>new_offset);

	ID_RR1: Register16 port map(d=>instr_in, clk=>clk, en=>decode_en, o=>instr_out);
	ID_RR3: Register16 port map(d=>sig_Imm, clk=>clk, en=>decode_en, o=>Imm);
	ID_RR4: Register16 port map(d=>PC_old_in, clk=>clk, en=>decode_en, o=>PC_old_out);
	 
				
	-- LM instr
	-- process(clk, lm_sm_imm, lm_sm_addr, offset, new_offset, lm_sm_complete)
	-- 	variable var_reg_addr : std_logic_vector(2 downto 0);
	-- 	variable var_new_lm_sm_imm : std_logic_vector(7 downto 0);

	-- 	begin
	-- 		var_new_lm_sm_imm:= instr_in(7 downto 0);

	-- 	if(var_new_lm_sm_imm(0) = '1') then
	-- 		var_reg_addr := "000";
	-- 		var_new_lm_sm_imm(0):= '0';
	-- 	elsif(var_new_lm_sm_imm(1) = '1') then
	-- 		var_reg_addr := "001";
	-- 		var_new_lm_sm_imm(1):= '0';
	-- 	elsif(var_new_lm_sm_imm(2) = '1') then
	-- 		var_reg_addr := "010";
	-- 		var_new_lm_sm_imm(2):= '0';
	-- 	elsif(var_new_lm_sm_imm(3) = '1') then
	-- 		var_reg_addr := "011";
	-- 		var_new_lm_sm_imm(3):= '0';
	-- 	elsif(var_new_lm_sm_imm(4) = '1') then
	-- 		var_reg_addr := "100";
	-- 		var_new_lm_sm_imm(4):= '0';
	-- 	elsif(var_new_lm_sm_imm(5) = '1') then
	-- 		var_reg_addr := "101";
	-- 		var_new_lm_sm_imm(5):= '0';
	-- 	elsif(var_new_lm_sm_imm(6) = '1') then
	-- 		var_reg_addr := "110";
	-- 		var_new_lm_sm_imm(6):= '0';
	-- 	elsif(var_new_lm_sm_imm(7) = '1') then
	-- 		var_reg_addr := "111";
	-- 		var_new_lm_sm_imm(7):= '0';
	-- 	else
	-- 		var_reg_addr := "000";
	-- 		var_new_lm_sm_imm := "00000000";
	-- 	end if;

	-- 	if(falling_edge(clk) and instr_in(14 downto 13) = "11") then
	-- 		if(var_new_lm_sm_imm = "00000000") then 
	-- 			lm_sm_complete <= '1';
	-- 		else
	-- 			lm_sm_addr <= var_reg_addr;
	-- 			lm_sm_imm <= var_new_lm_sm_imm;
	-- 			offset <= new_offset;
	-- 			lm_sm_complete <= '0';
	-- 		end if;
	-- 	end if;

	-- end process;

end Struct;


