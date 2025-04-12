library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lfsr_randomizer is
    port (
        clk : in std_logic;
        lfsr_out : out std_logic_vector(7 downto 0)
    );
end entity lfsr_randomizer;

architecture behavior of lfsr_randomizer is
    -- Signal declaration for the LFSR seed
    signal lfsr : std_logic_vector(15 downto 0) := x"ACE1"; -- Initial seed value

    signal lfsr_next : std_logic_vector(15 downto 0);

begin
    -- Assign the output of the LFSR to the lower 8 bits
    lfsr_next <= lfsr(14 downto 0) & (lfsr(15) xor lfsr(13) xor lfsr(12) xor lfsr(10));

    -- LFSR process runs on each clk edge
    process (clk, reset)
    begin
        if rising_edge(clk) then
            -- Update LFSR: shift left by one and compute the new bit as an XOR of selected taps:
            lfsr <= lfsr_next;
        end if;
    end process;
end architecture behavior;