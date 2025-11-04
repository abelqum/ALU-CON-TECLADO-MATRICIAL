library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity binbcd is
    Port ( 
        clk, reset: in std_logic;
        binario : in  STD_LOGIC_VECTOR (11 downto 0);
        bcd     : out STD_LOGIC_VECTOR (15 downto 0)
    );
end binbcd;

architecture Behavioral of binbcd is
begin
    process(clk, reset)
        variable temp_int : integer range 0 to 4095;
    begin
        if reset = '0' then
            bcd <= (others => '0');
        elsif rising_edge(clk) then
            temp_int := to_integer(unsigned(binario));
            
            bcd(15 downto 12) <= std_logic_vector(to_unsigned(temp_int / 1000, 4));
            bcd(11 downto 8)  <= std_logic_vector(to_unsigned((temp_int mod 1000) / 100, 4));
            bcd(7 downto 4)   <= std_logic_vector(to_unsigned((temp_int mod 100) / 10, 4));
            bcd(3 downto 0)   <= std_logic_vector(to_unsigned(temp_int mod 10, 4));
        end if;
    end process;
end Behavioral;