Library IEEE;
Use IEEE.std_logic_1164.all;
Use IEEE.numeric_std.all;

entity Divisor is
port(
    A, B: in std_logic_vector(5 downto 0);
    Activar: in std_logic;  -- Cambiado a std_logic en lugar de vector
    clk, reset: in std_logic;
    Resultado: out std_logic_vector(11 downto 0);
    Resto: out std_logic_vector(5 downto 0);
    error_division_cero: out std_logic
);
end Divisor;

architecture Behavioral of Divisor is
signal dividendo : unsigned(11 downto 0) := (others => '0');
signal divisor : unsigned(11 downto 0) := (others => '0');
signal cociente : integer := 0;
signal activo : std_logic := '0';
signal terminado : std_logic := '0';

begin

process(clk, reset)
begin
    if reset = '0' then
        dividendo <= (others => '0');
        divisor <= (others => '0');
        cociente <= 0;
        activo <= '0';
        terminado <= '0';
        Resultado <= (others => '0');
        Resto <= (others => '0');
        error_division_cero <= '0';
            
    elsif rising_edge(clk) then
        if Activar = '1' then  -- Ahora sí funciona porque Activar es std_logic
            if terminado = '0' then
                if activo = '0' then
                    -- Primer ciclo: inicializar
                    if B = "000000" then
                        error_division_cero <= '1';
                        Resultado <= (others => '0');
                        Resto <= (others => '0');
                        terminado <= '1';  -- Marcar como terminado
                    else
                        error_division_cero <= '0';
                        dividendo(5 downto 0) <= unsigned(A);
                        divisor(5 downto 0) <= unsigned(B);
                        cociente <= 0;
                        activo <= '1';
                    end if;
                    
                else
                    -- Ciclos siguientes: hacer restas
                    if dividendo >= divisor then
                        dividendo <= dividendo - divisor;
                        cociente <= cociente + 1;
                    else
                        -- Terminó: mostrar resultados y desactivar
                        Resultado <= std_logic_vector(to_unsigned(cociente, 12));
                        Resto <= std_logic_vector(dividendo(5 downto 0));
                        activo <= '0';
                        terminado <= '1';  -- Marcar como terminado
                    end if;
                end if;
            end if;
        end if;
    end if;
end process;

end Behavioral;