-- =====================================================
-- PROCESSADOR 8-BITS COMPLETO PARA EDA PLAYGROUND
-- =====================================================
-- Copie e cole TODO este arquivo no EDA Playground
-- Certifique-se de criar também o arquivo teste.bin
-- =====================================================

-- ========== PACKAGES ==========
library IEEE;
use IEEE.std_logic_1164.all;

package functions is
    function to_integer(signal vector : std_logic_vector) return integer;
end functions;

package body functions is
    function to_integer(signal vector : std_logic_vector) return integer is
        variable result : integer range 0 to 2**vector'length-1;
    begin
        if(vector(vector'high) = '1') then 
            result := 1;
        else 
            result := 0;
        end if;
        
        for i in (vector'high-1) downto (vector'low) loop
            result := result * 2;
            if(vector(i) = '1') then
                result := result + 1;
            end if;
        end loop;
        
        return result;
    end to_integer;
end functions;

-- ========== COMPONENTES BÁSICOS ==========

-- COMPLEMENTO DE 2
library IEEE;
use ieee.std_logic_1164.all;

entity COMPLEMENT_2_8_BITS_PORTS is port(
    output : out std_logic_vector(7 downto 0);
    input  : in  std_logic_vector(7 downto 0)
);  
end COMPLEMENT_2_8_BITS_PORTS;

architecture COMPLEMENT_2 of COMPLEMENT_2_8_BITS_PORTS is
begin
    process(input)
        variable temp : std_logic_vector(7 downto 0);
        variable carry : std_logic := '1';
    begin
        -- Inverte todos os bits
        for i in 0 to 7 loop
            temp(i) := not input(i);
        end loop;
        
        -- Adiciona 1
        for i in 0 to 7 loop
            if carry = '1' then
                if temp(i) = '0' then
                    temp(i) := '1';
                    carry := '0';
                else
                    temp(i) := '0';
                    carry := '1';
                end if;
            end if;
        end loop;
        
        output <= temp;
    end process;
end COMPLEMENT_2;

-- SOMADOR DE 1 BIT
library IEEE;
use ieee.std_logic_1164.all;

entity SUM_PORTS is port(
    cout : out std_logic;
    S    : out std_logic;
    A    : in  std_logic;
    B    : in  std_logic;
    cin  : in  std_logic
);
end SUM_PORTS;

architecture BIT_SUM of SUM_PORTS is
begin
    S <= A xor (B xor cin);
    cout <= (A and (B or cin)) or (B and cin);
end BIT_SUM;

-- SOMADOR DE 8 BITS
library IEEE;
use ieee.std_logic_1164.all;

entity SUM_8_BITS_PORTS is port(
    cout : out std_logic;
    S    : out std_logic_vector (7 downto 0);
    A    : in  std_logic_vector (7 downto 0);
    B    : in  std_logic_vector (7 downto 0);
    cin  : in  std_logic
);
end SUM_8_BITS_PORTS;

architecture SUM_8_BIT of SUM_8_BITS_PORTS is
    component SUM_PORTS is port(
        cout : out std_logic;
        S    : out std_logic;
        A    : in  std_logic;
        B    : in  std_logic;
        cin  : in  std_logic
    );
    end component;
    
    signal carry : std_logic_vector (8 downto 0);
begin
    carry(0) <= cin;
    
    G1: for i in 0 to 7 generate
        SX: SUM_PORTS port map(carry(i+1), S(i), A(i), B(i), carry(i));
    end generate G1;
    
    cout <= carry(8);
end SUM_8_BIT;

-- SUBTRATOR
library IEEE;
use ieee.std_logic_1164.all;

entity SUBTRACTION_8_BITS_PORTS is port(
    S     : out std_logic_vector (7 downto 0);
    carry : out std_logic;
    A     : in  std_logic_vector (7 downto 0);
    B     : in  std_logic_vector (7 downto 0)
); 
end SUBTRACTION_8_BITS_PORTS;

architecture SUBTRACTION_8_BIT of SUBTRACTION_8_BITS_PORTS is
    component COMPLEMENT_2_8_BITS_PORTS is port(
        output : out std_logic_vector(7 downto 0);
        input  : in  std_logic_vector(7 downto 0)
    );  
    end component;
    
    component SUM_8_BITS_PORTS is port(
        cout : out std_logic;
        S    : out std_logic_vector (7 downto 0);
        A    : in  std_logic_vector (7 downto 0);
        B    : in  std_logic_vector (7 downto 0);
        cin  : in  std_logic
    );
    end component;
    
    signal N_B : std_logic_vector (7 downto 0);
begin
    C2: COMPLEMENT_2_8_BITS_PORTS port map (N_B, B);
    SUMMATION: SUM_8_BITS_PORTS port map (carry, S, A, N_B, '0');
end SUBTRACTION_8_BIT;

-- COMPARADOR (versão simplificada)
library IEEE;
use ieee.std_logic_1164.all;

entity COMPARE is port (
    flag : out std_logic_vector(3 downto 0);
    A    : in  std_logic_vector (7 downto 0);
    B    : in  std_logic_vector (7 downto 0)
);
end COMPARE;

architecture COMPARE_ARCH of COMPARE is
begin
    process(A, B)
    begin
        flag <= "0000";
        
        if A = B then
            flag(0) <= '1';  -- Equal
        elsif A > B then
            flag(2) <= '1';  -- Greater
        else
            flag(1) <= '1';  -- Less
        end if;
    end process;
end COMPARE_ARCH;

-- BIT-WISE OPERATIONS
library IEEE;
use ieee.std_logic_1164.all;

entity BIT_WISE_PORTS is port(
    output : out std_logic_vector (7 downto 0);
    A      : in  std_logic_vector (7 downto 0);
    B      : in  std_logic_vector (7 downto 0);
    sel    : in  std_logic_vector (1 downto 0)
); 
end BIT_WISE_PORTS;

architecture BIT_WISE of BIT_WISE_PORTS is
begin
    process(A, B, sel)
    begin
        case sel is
            when "00" => output <= A and B;  -- AND
            when "01" => output <= A or B;   -- OR
            when "10" => output <= A xor B;  -- XOR
            when "11" => output <= not A;    -- NOT
            when others => output <= (others => '0');
        end case;
    end process;
end BIT_WISE;

-- MULTIPLICADOR (simplificado)
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MULT_PORTS is port (
    output   : out std_logic_vector (7 downto 0);
    carry    : out std_logic;
    flag     : out std_logic;
    input_A  : in  std_logic_vector (7 downto 0);
    input_B  : in  std_logic_vector (7 downto 0);
    clock    : in  std_logic;
    reset    : in  std_logic
); 
end MULT_PORTS;

architecture MULT of MULT_PORTS is
    signal result : unsigned(15 downto 0);
    signal done : std_logic := '0';
begin
    process(clock, reset)
    begin
        if reset = '1' then
            result <= (others => '0');
            done <= '0';
            flag <= '0';
        elsif rising_edge(clock) then
            if done = '0' then
                result <= unsigned(input_A) * unsigned(input_B);
                done <= '1';
                flag <= '1';
            end if;
        end if;
    end process;
    
    output <= std_logic_vector(result(7 downto 0));
    carry <= '1' when result > 255 else '0';
end MULT;

-- DIVISOR/MÓDULO (simplificado)
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MOD_DIV_PORTS is port(
    div_output : out std_logic_vector (7 downto 0);
    mod_output : out std_logic_vector (7 downto 0);
    flag       : out std_logic;
    input_A    : in  std_logic_vector (7 downto 0);
    input_B    : in  std_logic_vector (7 downto 0);
    clock      : in  std_logic;
    reset      : in  std_logic
); 
end MOD_DIV_PORTS;

architecture MOD_DIV of MOD_DIV_PORTS is
    signal done : std_logic := '0';
begin
    process(clock, reset)
        variable a_val, b_val : unsigned(7 downto 0);
    begin
        if reset = '1' then
            div_output <= (others => '0');
            mod_output <= (others => '0');
            done <= '0';
            flag <= '0';
        elsif rising_edge(clock) then
            if done = '0' then
                a_val := unsigned(input_A);
                b_val := unsigned(input_B);
                
                if b_val /= 0 then
                    div_output <= std_logic_vector(a_val / b_val);
                    mod_output <= std_logic_vector(a_val mod b_val);
                else
                    div_output <= (others => '1');
                    mod_output <= (others => '1');
                end if;
                
                done <= '1';
                flag <= '1';
            end if;
        end if;
    end process;
end MOD_DIV;

-- SHIFT LEFT (simplificado)
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity L_SHIFT_PORTS is port (
    output    : out std_logic_vector (7 downto 0);
    carry     : out std_logic;
    flag      : out std_logic;
    input     : in  std_logic_vector (7 downto 0);
    num_shift : in  std_logic_vector (7 downto 0);
    clock     : in  std_logic;
    reset     : in  std_logic
);
end L_SHIFT_PORTS;

architecture L_SHIFT of L_SHIFT_PORTS is
    signal done : std_logic := '0';
begin
    process(clock, reset)
        variable shift_amount : integer;
        variable temp : unsigned(7 downto 0);
    begin
        if reset = '1' then
            output <= (others => '0');
            carry <= '0';
            done <= '0';
            flag <= '0';
        elsif rising_edge(clock) then
            if done = '0' then
                temp := unsigned(input);
                shift_amount := to_integer(unsigned(num_shift));
                
                if shift_amount > 0 and shift_amount < 8 then
                    temp := shift_left(temp, shift_amount);
                end if;
                
                output <= std_logic_vector(temp);
                carry <= '0';
                done <= '1';
                flag <= '1';
            end if;
        end if;
    end process;
end L_SHIFT;

-- SHIFT RIGHT (simplificado)
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity R_SHIFT_PORTS is port (
    output    : out std_logic_vector (7 downto 0);
    carry     : out std_logic;
    flag      : out std_logic;
    input     : in  std_logic_vector (7 downto 0);
    num_shift : in  std_logic_vector (7 downto 0);
    clock     : in  std_logic;
    reset     : in  std_logic
);
end R_SHIFT_PORTS;

architecture R_SHIFT of R_SHIFT_PORTS is
    signal done : std_logic := '0';
begin
    process(clock, reset)
        variable shift_amount : integer;
        variable temp : unsigned(7 downto 0);
    begin
        if reset = '1' then
            output <= (others => '0');
            carry <= '0';
            done <= '0';
            flag <= '0';
        elsif rising_edge(clock) then
            if done = '0' then
                temp := unsigned(input);
                shift_amount := to_integer(unsigned(num_shift));
                
                if shift_amount > 0 and shift_amount < 8 then
                    temp := shift_right(temp, shift_amount);
                end if;
                
                output <= std_logic_vector(temp);
                carry <= '0';
                done <= '1';
                flag <= '1';
            end if;
        end if;
    end process;
end R_SHIFT;

-- Continua na próxima parte...
