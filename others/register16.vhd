library ieee;
use ieee.std_logic_1164.all;
package Register16Package is

	component Register16 is
		port (
			d : in std_logic_vector(15 downto 0); 
            clk : in std_logic; 
            en : in std_logic;  
            o : out std_logic_vector(15 downto 0) 
		);
	end component Register16;
	
end package Register16Package;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity Register16 is
     Port ( 
            d : in std_logic_vector(15 downto 0); 
            clk : in std_logic; 
            en : in std_logic;  
            o : out std_logic_vector(15 downto 0) 
);
end Register16;

architecture Register_behavioral of Register16 is 

signal in_d : std_logic_vector(15 downto 0); 

begin
process (clk) begin

 if rising_edge(clk) then
  if (en = '1') then
    o <= in_d;
  end if;
 end if;
 if falling_edge(clk) then
  --if (en = '1') then
    in_d <= d;
--  end if;
 end if;
end process;
end Register_behavioral; 
