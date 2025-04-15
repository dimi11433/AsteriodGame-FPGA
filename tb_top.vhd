library ieee;
use ieee.std_logic_1164.all;

entity tb_asteroids_top is
-- Testbench has no ports.
end tb_asteroids_top;

architecture sim of tb_asteroids_top is

    -- Component declaration for the unit under test.
    component asteroids_top is
        port(
            clk       : in  std_logic;
            reset     : in  std_logic;
            btnl      : in  std_logic;
            btnr      : in  std_logic;
            btnu      : in  std_logic;
            btnd      : in  std_logic;
            btnc      : in  std_logic;
            hsync     : out std_logic;
            vsync     : out std_logic;
            comp_sync : out std_logic;
            rgb       : out std_logic_vector(2 downto 0)
        );
    end component;

    -- Signal declarations for the UUT.
    signal clk       : std_logic := '0';
    signal reset     : std_logic := '1';
    signal btnl      : std_logic := '0';  -- Not pressed (assuming active low)
    signal btnr      : std_logic := '0';
    signal btnu      : std_logic := '0';
    signal btnd      : std_logic := '0';
    signal btnc      : std_logic := '0';
    signal hsync     : std_logic;
    signal vsync     : std_logic;
    signal comp_sync : std_logic;
    signal rgb       : std_logic_vector(2 downto 0);

begin

    -- Instantiate the Unit Under Test (UUT).
    uut: asteroids_top
        port map(
            clk       => clk,
            reset     => reset,
            btnl      => btnl,
            btnr      => btnr,
            btnu      => btnu,
            btnd      => btnd,
            btnc      => btnc,
            hsync     => hsync,
            vsync     => vsync,
            comp_sync => comp_sync,
            rgb       => rgb
        );

    --------------------------------------------------------------------
    -- Clock Generation Process (100 MHz: period = 10 ns)
    --------------------------------------------------------------------
    clk_gen: process
    begin
        while true loop
            clk <= '0';
            wait for 5 ns;
            clk <= '1';
            wait for 5 ns;
        end loop;
        wait;
    end process clk_gen;

    --------------------------------------------------------------------
    -- Reset Process: Assert reset for 20 ns then deassert.
    --------------------------------------------------------------------
    reset_proc: process
    begin
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait;  -- Remain in simulation
    end process reset_proc;

    --------------------------------------------------------------------
    -- Button C (btnc) Press Simulation Process
    --
    -- The btnc signal is driven high initially (not pressed), then 
    -- after 100 ns it is driven low (pressed) for 50 ns, then released.
    --------------------------------------------------------------------
    btnc_proc: process
    begin
        btnc <= '0';  -- no press at start
        wait for 100 ns;
        btnc <= '1';  -- simulate button press
        wait for 50 ns;  -- hold button pressed for 50 ns
        btnc <= '0';  -- release button
        wait;  -- End simulation (or continue as needed)
    end process btnc_proc;

end sim;