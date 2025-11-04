Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

Entity Calculadora is
    port(
        A : in std_logic_vector(15 downto 0);
        B : in std_logic_vector(15 downto 0);
        sel : in std_logic_vector(3 downto 0);
        clk : in std_logic;
        reset : in std_logic;
        resultado : out std_logic_vector(15 downto 0);
        error_div : out std_logic;
        flag_CF  : out std_logic;
        flag_ZF  : out std_logic;
        flag_SF  : out std_logic;
        flag_OvF : out std_logic
    );
end Calculadora;

Architecture Behavioral of Calculadora is
    
    component ALU12bits is
        port(
            A : in std_logic_vector(11 downto 0);
            B : in std_logic_vector(11 downto 0);
            sel : in std_logic_vector(3 downto 0);
            resultado : out std_logic_vector(11 downto 0);
            residuo : out std_logic_vector(5 downto 0);
            CF : out std_logic;
            ZF: out std_logic;
            SF: out std_logic;
            OvF: out std_logic;
            error_div : out std_logic
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

    ALU_instancia: ALU12bits 
        port map(
            A => binarioA,
            B => binarioB,
            sel => sel,
            resultado => resultadoALU,
            residuo   => restoALU,
            error_div => error_div,
            CF  => flag_CF,
            ZF  => flag_ZF,
            SF  => flag_SF,
            OvF => flag_OvF
        );

    BIN_to_BCD: binbcd 
        port map(
            clk => clk,
            reset => reset,
            binario => resultadoALU,
            bcd => resultado
        );
        
end Behavioral;
