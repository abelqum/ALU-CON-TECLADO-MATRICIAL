Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

Entity TCD is
    port(
        leds: out std_logic_vector(3 downto 0);
        fila : in std_logic_vector(3 downto 0);
        columnas : out std_logic_vector(3 downto 0);
        clk, enter : in std_logic;
        reset : in std_logic;
        enter_salida: out std_logic;
        seg: out std_logic_vector(0 to 7);
        an: out std_logic_vector(3 downto 0)
    );
end TCD;

Architecture Behavioral of TCD is

component Calculadora is
    port(
        A : in std_logic_vector(15 downto 0);
        B : in std_logic_vector(15 downto 0);
        sel : in std_logic_vector(3 downto 0);
        clk : in std_logic;
        reset : in std_logic;
        resultado : out std_logic_vector(15 downto 0);
        error_div : out std_logic
    );
end component;

component display is
    Port (
        Datos : in std_logic_vector(15 downto 0);
        clk_27mhz : in STD_LOGIC;
        seg : out STD_LOGIC_VECTOR(0 to 7);
        an : out STD_LOGIC_VECTOR(3 downto 0)
    );
end component;

component teclado is
    Port (
        clk_27mhz : in STD_LOGIC;
        reset : in STD_LOGIC;
        fila : in std_logic_vector(3 downto 0);
        columnas : out std_logic_vector(3 downto 0);
        enter : in std_logic;
        enter_out : out std_logic;
        numero : out std_logic_vector(15 downto 0)
    );
end component;

-- Signals
signal calc_resultado, Areg, Breg, OpReg, Intermediario, salida_teclado : std_logic_vector(15 downto 0);
signal enter_sal, enter_prev, enter_pulso : std_logic;

type estados is (num1, num2, op, res);
signal presente, siguiente: estados;

begin

-- Instanciación del teclado
TECLADO_INST: teclado
    port map(
        clk_27mhz => clk,
        reset => reset,
        fila => fila,
        columnas => columnas,
        enter => enter,
        enter_out => enter_sal,
        numero => salida_teclado
    );

-- Instanciación de la Calculadora
CALCULADORA_INST: Calculadora
    port map(
        A => Areg,
        B => Breg,
        sel => OpReg(3 downto 0),
        clk => clk,
        reset => reset,
        resultado => calc_resultado,
        error_div => open
    );

-- Instanciación del display
DISPLAY_INST: display
    port map(
        Datos => Intermediario,
        clk_27mhz => clk,
        seg => seg,
        an => an
    );

-- Detección de flanco de bajada para enter (1 solo ciclo) a 27MHz
process(clk)
begin
    if rising_edge(clk) then
        enter_prev <= enter_sal;
        enter_pulso <= '0';
        
        -- Detectar flanco de bajada (1 -> 0) - enter activo en bajo
        if enter_prev = '1' and enter_sal = '0' then
            enter_pulso <= '1';
        end if;
    end if;
end process;

enter_salida <= not enter_sal;

-- Máquina de estados principal a 27MHz
process(clk, reset)
begin
    if reset = '0' then
        presente <= num1;
    elsif rising_edge(clk) then
        presente <= siguiente;
    end if;
end process;

-- Lógica de la máquina de estados a 27MHz
process(clk, reset)
begin
    if reset = '0' then
        Areg <= (others => '0');
        Breg <= (others => '0');
        OpReg <= (others => '0');
        siguiente <= num1;
    elsif rising_edge(clk) then
        case presente is
            when num1 => 
                leds <= "0001";
                Areg <= salida_teclado;
                Intermediario <= Areg;
                if enter_pulso = '1' then  -- Solo con pulso de 1 ciclo
                    siguiente <= num2;
                end if;
                
            when num2 => 
                leds <= "0010";
                Breg <= salida_teclado;
                Intermediario <= Breg;
                if enter_pulso = '1' then  -- Solo con pulso de 1 ciclo
                    siguiente <= op;
                end if;
                
            when op => 
                leds <= "0100";
                OpReg <= salida_teclado;
                Intermediario <= OpReg;
                if enter_pulso = '1' then  -- Solo con pulso de 1 ciclo
                    siguiente <= res;
                end if;
                
            when res => 
                leds <= "1000";
                Intermediario <= calc_resultado;
                -- Permanecer en res hasta nuevo enter
                if enter_pulso = '1' then  -- Volver al inicio
                    siguiente <= num1;
                end if;
                
            when others =>
                siguiente <= num1;
        end case;
    end if;
end process;

end Behavioral;