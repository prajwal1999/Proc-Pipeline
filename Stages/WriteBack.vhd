library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package Write_BackPackage is
	component Write_Back is
		port ( 
			wb_en, clk: in std_logic;
			instr_in, data_in1, data_in2: in std_logic_vector(15 downto 0);			-- opcode-4 dest-3 bypass_equal 6-0 C-1 Z-1 
			data_out, PC_out, instr_out: out std_logic_vector(15 downto 0);
			dest: out std_logic_vector(2 downto 0)
		);
	end component Write_Back;
end package Write_BackPackage;



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.Register16Package.all;

entity Write_Back is
   port ( 
			wb_en, clk: in std_logic;
			instr_in, data_in1, data_in2: in std_logic_vector(15 downto 0);			-- opcode-4 dest-3 bypass_equal 6-0 C-1 Z-1 
			data_out, PC_out, instr_out: out std_logic_vector(15 downto 0);
			dest: out std_logic_vector(2 downto 0)
	);
end entity Write_Back;

architecture Struct of Write_Back is
	signal sig_data_out, sig_pc_out: std_logic_vector(15 downto 0);
	begin
		
		sig_data_out <= x"0000" when instr_in(11 downto 0)="111" else
						data_in1;

		sig_pc_out <= data_in1 when instr_in(11 downto 0)="111" else
					data_in2;
	
	

	process (clk, wb_en)
			begin

				if(falling_edge(clk) and wb_en='1') then
					dest<= instr_in(11 downto 9);
					instr_out <= instr_in;
					data_out <= sig_data_out;
					PC_out <= sig_pc_out;
				end if;

		end process;
	
end Struct;
