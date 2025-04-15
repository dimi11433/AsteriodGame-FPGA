library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity asteroid_graph is
    port (
        clk, reset : in std_logic;
        pixel_tick : in std_logic;
        video_on : in std_logic;
        pixel_x : in std_logic_vector(9 downto 0);
        pixel_y : in std_logic_vector(9 downto 0);
        btnl, btnr : in std_logic;
        btnu, btnd : in std_logic;
        btnc : in std_logic;
        graph_rgb : out std_logic_vector(2 downto 0)
    );
end asteroid_graph;

architecture asteroid_arch of asteroid_graph is
    constant SCREEN_WIDTH : integer := 640;
    constant SCREEN_HEIGHT : integer := 480;

    constant ASTEROID_SIZE : integer := 8;

    constant ASTEROID_DY : integer := 1;

    signal pix_x, pix_y : unsigned(9 downto 0);
    signal asteroid_rom_bit : std_logic;

    signal asteroid_x_start, asteroid_x_end : unsigned(9 downto 0);
    signal asteroid_y_top, asteroid_y_bottom : unsigned(9 downto 0);

    -- next start positions for the objects
    signal asteroid_x_start_next, asteroid_y_top_next : unsigned(9 downto 0);

    signal asteroid_on, alien_1_on, spaceship_on, info_section_on, missile_on : std_logic;

    signal alien_color, spaceship_color, asteroid_color, info_section_color, missile_color : std_logic_vector(2 downto 0);

    signal refresh_screen : std_logic;

    signal alien_1_active, alien_2_active : std_logic;

    signal collision_with_asteroid, collision_with_alien : std_logic;

    signal collision_with_asteroid_happened : std_logic;

    signal number_of_lives : unsigned(1 downto 0);

    signal launch_missile : std_logic;

    signal missile_x, missile_y : unsigned(9 downto 0);

    -- asteroid image
    type rom_type_8 is array(0 to 7) of std_logic_vector(0 to 7);
    constant ASTEROID_ROM : rom_type_8 := (
        "00111100",
        "01111110",
        "11111111",
        "11111111",
        "11111111",
        "11111111",
        "01111110",
        "00111100"
    );

begin

    -- instantiate the spaceship graph
    spaceship_graph_unit : entity work.spaceship_graph
        port map(
            clk => clk,
            reset => reset,
            pixel_tick => pixel_tick,
            pixel_x => pix_x,
            pixel_y => pix_y,
            btnl => btnl,
            btnr => btnr,
            btnu => btnu,
            btnd => btnd,
            btnc => btnc,
            refresh_screen => refresh_screen,
            collision => collision_with_asteroid or collision_with_alien,
            number_of_lives => number_of_lives,
            spaceship_on => spaceship_on,
            missile_x => missile_x,
            missile_y => missile_y,
            launch_missile => launch_missile
        );
    
    -- instantiate the alien graph
    alien_graph_unit : entity work.alien_1_graph
        port map(
            clk => clk,
            reset => reset,
            pixel_x => pix_x,
            pixel_y => pix_y,
            refresh_screen => refresh_screen,
            active => alien_1_active,
            alien_on => alien_1_on,
            collision => collision_with_alien
        );

    -- instantiate the info section graph
    info_section_graph_unit : entity work.info_section_graph
        port map(
            clk => clk,
            reset => reset,
            pixel_x => pix_x,
            pixel_y => pix_y,
            refresh_screen => refresh_screen,
            collision => collision_with_asteroid or collision_with_alien,
            number_of_lives => number_of_lives,
            info_section_on => info_section_on
        );

    missile_graph_unit : entity work.missile_graph
        port map(
            clk => clk,
            reset => reset,
            pixel_tick => pixel_tick,
            pixel_x => pix_x,
            pixel_y => pix_y,
            refresh_screen => refresh_screen,
            missile_x =>  missile_x,
            missile_y => missile_y,
            launch_missile => launch_missile,
            missile_on => missile_on
        );

    pix_x <= unsigned(pixel_x);
    pix_y <= unsigned(pixel_y);

    alien_color <= "110"; -- purple
    spaceship_color <= "010"; -- green
    asteroid_color <= "111"; -- white/greyish
    missile_color <= "111"; -- black
    info_section_color <= "111"; -- black

    asteroid_rom_bit <= ASTEROID_ROM(to_integer(pix_y) - to_integer(asteroid_y_top))(to_integer(pix_x) - to_integer(asteroid_x_start));

    asteroid_on <= '1' when (pix_x >= asteroid_x_start and pix_x <= asteroid_x_end) and
        (pix_y >= asteroid_y_top and pix_y <= asteroid_y_bottom) and (asteroid_rom_bit = '1') else
        '0';

    asteroid_x_end <= asteroid_x_start + ASTEROID_SIZE - 1;
    asteroid_y_bottom <= asteroid_y_top + ASTEROID_SIZE - 1;

    refresh_screen <= '1' when (pix_x = to_unsigned(SCREEN_WIDTH - 1, 10) and
        pix_y = to_unsigned(SCREEN_HEIGHT - 1, 10) and pixel_tick = '1') else
        '0';

    collision_with_asteroid <= '1' when (spaceship_on = '1' and asteroid_on = '1') else
        '0';

    collision_with_alien <= '1' when (alien_1_on = '1' and spaceship_on = '1') else
        '0';

    alien_1_active <= '1'; 

    -- move the asteroid
    process (asteroid_y_top)
    begin
        if asteroid_y_top < to_unsigned(SCREEN_HEIGHT - ASTEROID_SIZE, 10) then
            asteroid_y_top_next <= asteroid_y_top + ASTEROID_DY;
        else
            asteroid_y_top_next <= to_unsigned(0, 10);
        end if;
    end process;

    -- at reset, set the initial positions of the objects
    process (clk, reset)
    begin
        if reset = '1' then
            asteroid_x_start <= to_unsigned(SCREEN_WIDTH / 2 - ASTEROID_SIZE / 2, 10);
            asteroid_y_top <= (others => '0');
        elsif rising_edge(clk) then
            if refresh_screen = '1' then
                if collision_with_asteroid_happened = '1' then
                    asteroid_y_top <= to_unsigned(0, 10);
                    collision_with_asteroid_happened <= '0';
                else
                    asteroid_y_top <= asteroid_y_top_next;
                end if;
            end if;

            if collision_with_asteroid = '1' then
                collision_with_asteroid_happened <= '1';
            end if;
        end if;
    end process;

    process (video_on, alien_1_on, spaceship_on, asteroid_on)
    begin
        if video_on = '1' then
            if info_section_on = '1' then
                graph_rgb <= info_section_color;
            elsif missile_on = '1' then
                graph_rgb <= missile_color;
            elsif alien_1_on = '1' then
                graph_rgb <= alien_color;
            elsif spaceship_on = '1' then
                graph_rgb <= spaceship_color;
            elsif asteroid_on = '1' then
                graph_rgb <= asteroid_color;
            else
                graph_rgb <= "000"; -- black
            end if;
        else
            graph_rgb <= "000"; -- black
        end if;
    end process;
end asteroid_arch;