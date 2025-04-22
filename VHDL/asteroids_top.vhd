library ieee;
use ieee.std_logic_1164.all;
entity asteroids_top is
    port (
        clk, reset : in std_logic; -- System clock and synchronous reset
        pause : in std_logic; -- Pause control
        btnl, btnr : in std_logic; -- Left/right movement controls for the spaceship
        btnu, btnd : in std_logic; -- Up/down movement controls for the spaceship
        btnc : in std_logic; -- Controls shooting missiles
        sw15, sw14, sw13 : in std_logic; -- Switches for controlling the alien
        sw1 : in std_logic; -- Enables manual alien control; off = automatic
        hsync, vsync, comp_sync : out std_logic; -- VGA horizontal, vertical, and composite sync outputs
        rgb : out std_logic_vector(2 downto 0) -- RGB color output to VGA
    );
end asteroids_top;

architecture arch of asteroids_top is
    signal pixel_x, pixel_y : std_logic_vector(9 downto 0) := (others => '0');
    signal video_on, pixel_tick : std_logic := '0';
    signal rgb_reg, rgb_next : std_logic_vector(2 downto 0);
begin
    -- instantiate VGA sync
    vga_sync_unit : entity work.vga_sync
        port map(
            clk => clk,
            reset => reset,
            video_on => video_on,
            p_tick => pixel_tick,
            hsync => hsync, vsync => vsync,
            comp_sync => comp_sync,
            pixel_x => pixel_x,
            pixel_y => pixel_y
        );
    -- instantiate pixel generation circuit
    asteroids_graph_unit : entity work.asteroid_graph(asteroid_arch)
        port map(
            clk => clk,
            rst => reset,
            pause => pause,
            pixel_tick => pixel_tick,
            video_on => video_on,
            pixel_x => pixel_x,
            pixel_y => pixel_y,
            btnl => btnl,
            btnr => btnr,
            btnu => btnu,
            btnd => btnd,
            btnc => btnc,
            sw15 => sw15,
            sw14 => sw14,
            sw13 => sw13,
            sw1 => sw1,
            graph_rgb => rgb_next);
    -- rgb buffer, graph_rgb is routed to the ouput through
    -- an output buffer -- loaded when pixel_tick = ’1’.
    -- This syncs. rgb output with buffered hsync/vsync sig.
    process (clk)
    begin
        if (rising_edge(clk)) then
            if (pixel_tick = '1') then
                rgb_reg <= rgb_next;
            end if;
        end if;
    end process;
    rgb <= rgb_reg;
end arch;