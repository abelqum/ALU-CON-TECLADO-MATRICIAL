Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

Entity TCD is
    port(
        leds: out std_logic_vector(3 downto 0);
        fila : in std_logic_vector(3 downto 0);
        columnas : out std_logic_vector(3 downto 0);
        clk : in std_logic;
        reset : in std_logic;
        -- Puerto 'enter' eliminado (ya no es necesario)
        seg: out std_logic_vector(0 to 7);
        an: out std_logic_vector(3 downto 0);
        
        -- --- PUERTOS NUEVOS PARA LEDS EXTERNOS ---
        ledsd: out std_logic_vector(3 downto 0)
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
            error_div : out std_logic;
            flag_CF  : out std_logic;
            flag_ZF  : out std_logic;
            flag_SF  : out std_logic;
            flag_OvF : out std_logic
        );
    end component;

    -- Componente 'display' actualizado con puerto 'signo'
    component display is
        Port (
            Datos : in std_logic_vector(15 downto 0);
            clk_27mhz : in STD_LOGIC;
            signo : in STD_LOGIC; -- Puerto nuevo
            seg : out STD_LOGIC_VECTOR(0 to 7);
            an : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    -- Componente 'teclado' actualizado (sin 'enter')
    component teclado is
        Port (
            clk_27mhz : in STD_LOGIC;
            reset : in STD_LOGIC;
            fila : in std_logic_vector(3 downto 0);
            columnas : out std_logic_vector(3 downto 0);
            enter_out : out std_logic;
            numero : out std_logic_vector(15 downto 0)
        );
    end component;

    signal calc_resultado, Areg, Breg, OpReg, Intermediario, salida_teclado : std_logic_vector(15 downto 0);
    signal enter_sal, enter_prev, enter_pulso : std_logic;
    type estados is (num1, num2, op, res);
    signal presente, siguiente: estados;
    
    signal s_flag_CF  : std_logic;
    signal s_flag_ZF  : std_logic;
    signal s_flag_SF  : std_logic;
    signal s_flag_OvF : std_logic;
    signal s_error_div: std_logic;

begin

    -- Instanciación 'teclado' actualizada (sin 'enter')
    TECLADO_INST: teclado
        port map(
            clk_27mhz => clk,
            reset => reset,
            fila => fila,
            columnas => columnas,
            enter_out => enter_sal,
            numero => salida_teclado
        );

    CALCULADORA_INST: Calculadora
        port map(
            A => Areg,
            B => Breg,
            sel => OpReg(3 downto 0),
            clk => clk,
            reset => reset,
            resultado => calc_resultado,
            error_div => s_error_div,
            flag_CF  => s_flag_CF,
            flag_ZF  => s_flag_ZF,
            flag_SF  => s_flag_SF,
            flag_OvF => s_flag_OvF
        );

    -- Instanciación 'display' actualizada con 'signo'
    DISPLAY_INST: display
        port map(
            Datos => Intermediario,
            clk_27mhz => clk,
            signo => s_flag_SF, -- Conexión nueva
            seg => seg,
            an => an
        );

    -- --- ASIGNACIÓN DE LEDS EXTERNOS ---
 ledsd<= s_flag_CF&s_flag_ZF&s_flag_SF&s_flag_OvF;

    -- Proceso para crear un pulso de 1 ciclo para 'enter' (tecla 'A')
    process(clk)
    begin
        if rising_edge(clk) then
            enter_prev <= enter_sal;
            enter_pulso <= '0';
            
            if enter_prev = '1' and enter_sal = '0' then -- Detecta flanco de bajada
                enter_pulso <= '1';
            end if;
        end if;
    end process;

    process(clk, reset)
    begin
        if reset = '0' then
            presente <= num1;
        elsif rising_edge(clk) then
            presente <= siguiente;
        end if;
    end process;

    -- FSM Principal (Lógica corregida)
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
                    if enter_pulso = '1' then -- Lógica corregida
                        siguiente <= num2;
                    end if;
                    
                when num2 => 
                    leds <= "0010";
                    Breg <= salida_teclado;
                    Intermediario <= Breg;
                    if enter_pulso = '1' then -- Lógica corregida
                        siguiente <= op;
                    end if;
                    
                when op => 
                    leds <= "0100";
                    OpReg <= salida_teclado;
                    Intermediario <= OpReg;
                    if enter_pulso = '1' then -- Lógica corregida
                        siguiente <= res;
                    end if;
                    
                when res => 
                    leds <= "1000";
                    Intermediario <= calc_resultado;
                    if enter_pulso = '1' then -- Lógica corregida
                        siguiente <= num1;
                    end if;
                    
                when others =>
                    siguiente <= num1;
            end case;
        end if;
    end process;

end Behavioral;
