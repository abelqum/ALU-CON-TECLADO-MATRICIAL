Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

Entity Calculadora is
    port(
        A : in std_logic_vector(15 downto 0);      -- Operando A BCD
        B : in std_logic_vector(15 downto 0);      -- Operando B BCD
        sel : in std_logic_vector(3 downto 0);     -- Selector de operación
        clk : in std_logic;                        -- Reloj para mult/div
        reset : in std_logic;                      -- Reset para mult/div
        resultado : out std_logic_vector(15 downto 0); -- Resultado EN BCD
        error_div : out std_logic                  -- Error división por cero
    );
end Calculadora;

Architecture Behavioral of Calculadora is
    
component ALU12bits is
    port(
        A : in std_logic_vector(11 downto 0);      -- Operando A
        B : in std_logic_vector(11 downto 0);      -- Operando B
        sel : in std_logic_vector(3 downto 0);     -- Selector de operación
        clk : in std_logic;                        -- Reloj para mult/div
        reset : in std_logic;                      -- Reset para mult/div
        resultado : out std_logic_vector(11 downto 0); -- Resultado
        resto : out std_logic_vector(5 downto 0);      -- Resto de división
        c_out : out std_logic;                     -- Acarreo
        error_div : out std_logic                  -- Error división por cero
    );
end component;

component bcdbin is
    Port ( 
        clk, reset: in std_logic;
        bcd     : in  STD_LOGIC_VECTOR (15 downto 0);
        binario : out STD_LOGIC_VECTOR (11 downto 0)
    );
end component;

component binbcd is
    Port ( 
        clk, reset: in std_logic;
        binario : in  STD_LOGIC_VECTOR (11 downto 0);
        bcd     : out STD_LOGIC_VECTOR (15 downto 0)
    );
end component;
    
   

signal binarioA,binarioB,resultadoALU: std_logic_vector(11 downto 0);
    signal restoALU: std_logic_vector(5 downto 0):=(others=>'0');
signal coutALU:std_logic:='0';
begin

BCD_to_BINA: bcdbin 
    port map(
        clk => clk,
        reset => reset,
        bcd => A,
        binario => binarioA
    );

BCD_to_BINB: bcdbin 
    port map(
        clk => clk,
        reset => reset,
        bcd => B,
        binario => binarioB
    );


-- Instanciación de la ALU
ALU_instancia: ALU12bits 
    port map(
        A => binarioA,
        B => binarioB,
        sel => sel,
        clk => clk,
        reset => reset,
        resultado => resultadoALU,
        resto => restoALU,
        c_out => coutALU,
        error_div => error_div
    );


BIN_to_BCD: binbcd 
    port map(
        clk => clk,
        reset => reset,
        binario => resultadoALU,
        bcd => resultado
    );
   
end Behavioral;