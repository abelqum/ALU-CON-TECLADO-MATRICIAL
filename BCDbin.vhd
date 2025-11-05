library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bcdbin is
    Port ( 
        clk, reset: in std_logic;
        bcd     : in  STD_LOGIC_VECTOR (15 downto 0);
        binario : out STD_LOGIC_VECTOR (11 downto 0)
    );
end bcdbin;

architecture Behavioral of bcdbin is
begin
    process(clk, reset)
        variable digito3, digito2, digito1, digito0 : integer range 0 to 9;
        variable resultado : integer range 0 to 4095;
        variable temp_result : integer;
    begin
        if reset = '0' then
            binario <= (others => '0');
        elsif rising_edge(clk) then
            -- Extraer cada dígito BCD
            digito3 := to_integer(unsigned(bcd(15 downto 12)));
            digito2 := to_integer(unsigned(bcd(11 downto 8)));
            digito1 := to_integer(unsigned(bcd(7 downto 4)));
            digito0 := to_integer(unsigned(bcd(3 downto 0)));
            
            -- Calcular valor binario temporal
            temp_result := (digito3 * 1000) + (digito2 * 100) + (digito1 * 10) + digito0;
            
            -- Validar si excede 4095 (máximo para 12 bits)
            if temp_result > 4095 then
                resultado := 0;  -- Si es mayor a 4095, salida = 0
            else
                resultado := temp_result;
            end if;
            
            -- Convertir a vector
            binario <= std_logic_vector(to_unsigned(resultado, 12));
        end if;
    end process;
end Behavioral;
