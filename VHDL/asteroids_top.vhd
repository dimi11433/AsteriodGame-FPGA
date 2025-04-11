library ieee;
use ieee.std_logic_1164.all;
entity asteroids_top is
    port (
        clk, reset : in std_logic;
        btnl, btnr : in std_logic;
        btnu, btnd : in std_logic;
        btnc : in std_logic;
        hsync, vsync, comp_sync : out std_logic;
        rgb : out std_logic_vector(2 downto 0)
    );
end asteroids_top;

architecture arch of asteroids_top is
    signal pixel_x, pixel_y : std_logic_vector(9 downto 0);
    signal video_on, pixel_tick : std_logic;
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
            reset => reset,
            pixel_tick => pixel_tick,
            video_on => video_on,
            pixel_x => pixel_x,
            pixel_y => pixel_y,
            btnl => btnl,
            btnr => btnr,
            btnu => btnu,
            btnd => btnd,
            btnc => btnc,
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