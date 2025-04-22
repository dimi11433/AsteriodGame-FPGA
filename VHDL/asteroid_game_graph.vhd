-- Asteroid game graphics module: renders asteroids, spaceship, alien, missiles, and info over VGA

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity asteroid_graph is
    port (
        clk, rst : in std_logic;
        pixel_tick : in std_logic; 
        video_on : in std_logic; 
        pixel_x : in std_logic_vector(9 downto 0); 
        pixel_y : in std_logic_vector(9 downto 0); 
        btnl, btnr : in std_logic; 
        btnu, btnd : in std_logic; 
        btnc : in std_logic; 
        sw15, sw14, sw13 : in std_logic; 
        sw1 : in std_logic; 
        graph_rgb : out std_logic_vector(2 downto 0) 
    );
end asteroid_graph;

architecture asteroid_arch of asteroid_graph is
    constant SCREEN_WIDTH : integer := 640; 
    constant SCREEN_HEIGHT : integer := 480; 
    constant ASTEROID_SIZE : integer := 8; 
    constant ASTEROID_DY : integer := 1; 

    signal reset : std_logic;

    -- Signal declarations
    -- VGA current pixel coordinates
    signal pix_x, pix_y : unsigned(9 downto 0); 

    signal asteroid_rom_bit : std_logic; -- Current pixel color from the asteroid ROM Bitmap

    -- Asteroid sprite bounding box (coordinates)
    signal asteroid_x_start, asteroid_x_end : unsigned(9 downto 0); 
    signal asteroid_y_top, asteroid_y_bottom : unsigned(9 downto 0); 

    -- Asteroid sprite next position (coordinates)
    signal asteroid_x_start_next, asteroid_y_top_next : unsigned(9 downto 0); 

    -- On signal for each object to determine if it should be rendered
    signal asteroid_on, alien_1_on, spaceship_on : std_logic;
    signal info_section_on, missile_on, asteroids_on, game_over_text_on, game_start_text_on, alien_missile_on : std_logic;

    -- Color signals for each object 
    signal alien_color, spaceship_color, asteroid_color, info_section_color, missile_color, multiasteroid_color : std_logic_vector(2 downto 0); 


    signal refresh_screen : std_logic; 

    signal alien_1_active : std_logic;

    -- Collision detection signals for various objects
    signal spaceship_collision_with_asteroid, spaceship_collision_with_alien, spaceship_collision: std_logic; 
    signal missile_collision_with_alien, missile_collision_with_spaceship : std_logic; 
    signal spaceship_collision_with_asteroid_happened : std_logic;
    -- Game over tracking signals
    signal number_of_lives : unsigned(1 downto 0); 
    signal game_over : std_logic;

    -- Game start tracking signals
    signal game_start : std_logic;
    signal game_starting : unsigned(8 downto 0);

    -- Missile launch signal and coordinates
    signal launch_missile : std_logic; 
    signal missile_x, missile_y : unsigned(9 downto 0); 

    -- Alien Missile launch signal and coordinates
    signal launch_alien_missile : std_logic; 
    signal alien_missile_x, alien_missile_y : unsigned(9 downto 0); 

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
    asteroid_gen_unit : entity work.asteroid_gen
        port map(
            clk => clk,
            reset => reset,
            pixel_tick => pixel_tick,
            video_on  => video_on,
            refresh_screen => refresh_screen,
            spaceship_on => spaceship_on,
            pixel_x  => pixel_x,
            pixel_y  => pixel_y,
            asteroid_on_certainly => asteroids_on
        );

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
            collision => spaceship_collision,
            number_of_lives => number_of_lives,
            spaceship_on => spaceship_on,
            missile_x => missile_x,
            missile_y => missile_y,
            launch_missile => launch_missile
        );

    alien_graph_unit : entity work.alien_1_graph
        port map(
            clk => clk,
            reset => reset,
            pixel_x => pix_x,
            pixel_y => pix_y,
            btnl => sw15,
            btnr => sw14,
            btnc => sw13,
            automatic_or_manual => sw1,
            refresh_screen => refresh_screen,
            active => alien_1_active,
            alien_on => alien_1_on,
            collision => spaceship_collision_with_alien or missile_collision_with_alien,
            alien_missile_x => alien_missile_x,
            alien_missile_y => alien_missile_y,
            launch_missile => launch_alien_missile
        );

    info_section_graph_unit : entity work.info_section_graph
        port map(
            clk => clk,
            reset => reset,
            pixel_x => pix_x,
            pixel_y => pix_y,
            refresh_screen => refresh_screen,
            collision => spaceship_collision,
            number_of_lives => number_of_lives,
            info_section_on => info_section_on
        );

    spaceship_missile_graph_unit : entity work.spaceship_missile_graph
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
            alien_on => alien_1_on,
            asteroid_on => asteroid_on,
            alien_missile_on => alien_missile_on,
            asteroids_on => asteroids_on,
            missile_on => missile_on
        );

    alien_missile_graph_unit : entity work.alien_missile_graph
        port map(
            clk => clk,
            reset => reset,
            pixel_tick => pixel_tick,
            pixel_x => pix_x,
            pixel_y => pix_y,
            refresh_screen => refresh_screen,
            missile_x =>  alien_missile_x,
            missile_y => alien_missile_y,
            launch_missile => launch_alien_missile,
            spaceship_on => spaceship_on,
            spaceship_missile_on => missile_on,
            missile_on => alien_missile_on
        );

    -- Game over text display
    game_over_display : entity work.display_text
        port map(
            clk     => clk,
            reset   => reset,
            pixel_x => pix_x,
            pixel_y => pix_y,
            enable  => game_over,
            text_on => game_over_text_on
        );

    -- Game start text display
    game_start_display : entity work.game_start_graph
        port map(
            clk     => clk,
            reset   => reset,
            pixel_x => pix_x,
            pixel_y => pix_y,
            enable  => game_start,
            text_on => game_start_text_on
        );

    reset <= '1' when (rst = '1' or game_start = '1' or game_over = '1') else
        '0';

    -- Convert pixel_x and pixel_y to unsigned for arithmetic operations
    pix_x <= unsigned(pixel_x); 
    pix_y <= unsigned(pixel_y); 

    alien_color <= "110"; 
    spaceship_color <= "010"; 
    asteroid_color <= "111"; 
    missile_color <= "111"; 
    info_section_color <= "111"; 
    multiasteroid_color <= "111"; 

    -- Determine the bitmap bit for the current pixel within the asteroid sprite
    asteroid_rom_bit <= ASTEROID_ROM(to_integer(pix_y(2 downto 0) - asteroid_y_top(2 downto 0)))(to_integer(pix_x(2 downto 0) - asteroid_x_start(2 downto 0))); 

    -- Render asteroid pixel: check bounding box and ROM bit
    asteroid_on <= '1' when (pix_x >= asteroid_x_start and pix_x <= asteroid_x_end) and
        (pix_y >= asteroid_y_top and pix_y <= asteroid_y_bottom) and (asteroid_rom_bit = '1') else
        '0'; 

    asteroid_x_end <= asteroid_x_start + ASTEROID_SIZE - 1; 
    asteroid_y_bottom <= asteroid_y_top + ASTEROID_SIZE - 1; 

    -- Generate a pulse at the last pixel of each frame to trigger object updates
    refresh_screen <= '1' when (pix_x = to_unsigned(SCREEN_WIDTH - 1, 10) and
        pix_y = to_unsigned(SCREEN_HEIGHT - 1, 10) and pixel_tick = '1') else
        '0'; 

    -- Collision detection: set flag when two sprite regions overlap
    spaceship_collision_with_asteroid <= '1' when (spaceship_on = '1' and (asteroid_on = '1' or asteroids_on = '1')) else
        '0'; 

    -- Collision detection: set flag when two sprite regions overlap
    spaceship_collision_with_alien <= '1' when (alien_1_on = '1' and spaceship_on = '1') else
        '0'; 

    -- Collision detection: set flag when two sprite regions overlap
    missile_collision_with_alien <= '1' when (missile_on = '1' and alien_1_on = '1') else
        '0'; 

    -- Collision detection: set flag when two sprite regions overlap
    missile_collision_with_spaceship <= '1' when (alien_missile_on = '1' and spaceship_on = '1') else
        '0';

    spaceship_collision <= (spaceship_collision_with_asteroid or
        spaceship_collision_with_alien or
        missile_collision_with_spaceship);

    alien_1_active <= '1';

    game_start <= '1' when (game_starting > 0) else
        '0';

    -- Asteroid movement: update vertical position each frame, wrap around at bottom
    process (asteroid_y_top)
    begin
        if asteroid_y_top < to_unsigned(SCREEN_HEIGHT - ASTEROID_SIZE, 10) then
            asteroid_y_top_next <= asteroid_y_top + ASTEROID_DY;
        else
            asteroid_y_top_next <= to_unsigned(0, 10);
        end if;
    end process;


    -- Position initialization and update: reset positions and handle asteroid respawn after collision
    process (clk, rst)
    begin
        if rst = '1' then
            asteroid_x_start <= to_unsigned(SCREEN_WIDTH / 2 - ASTEROID_SIZE / 2, 10);
            asteroid_y_top <= (others => '0');
        elsif rising_edge(clk) then
            if refresh_screen = '1' then
                if spaceship_collision_with_asteroid_happened = '1' then
                    asteroid_y_top <= to_unsigned(0, 10);
                    spaceship_collision_with_asteroid_happened <= '0';
                else
                    asteroid_y_top <= asteroid_y_top_next;
                end if;
                
            end if;
            if spaceship_collision_with_asteroid = '1' then
                spaceship_collision_with_asteroid_happened <= '1';
            end if;        
        end if;
    end process;

    -- Game over logic: assert when player lives reach zero
    process (clk, rst)
    begin
        if rst = '1' then
            game_over <= '0';
        elsif rising_edge(clk) then
            if number_of_lives = "00" then
                game_over <= '1';
            end if;
        end if;
    end process;

    -- Game start logic: assert when game is starting
    process (clk, rst)
    begin
        if rst = '1' then
            game_starting <= "100000100";
        elsif rising_edge(clk) then
            if refresh_screen = '1' then
                if game_starting > 0 then
                    game_starting <= game_starting - 1;
                end if;
            end if;
        end if;
    end process;

    -- Rendering priority: choose which sprite's color outputs for each pixel
    process (video_on, alien_1_on, spaceship_on, asteroid_on, missile_on, asteroids_on, game_over_text_on, game_over, info_section_on, alien_missile_on, game_start, game_start_text_on)
    begin
        if video_on = '1' then
            if game_start = '1' then
                if game_start_text_on = '1' then
                    graph_rgb <= "111"; 
                else
                    graph_rgb <= "000"; 
                end if;
            elsif game_over = '1' then
                if game_over_text_on = '1' then
                    graph_rgb <= "111"; 
                else
                    graph_rgb <= "000"; 
                end if;
            else
                if info_section_on = '1' then
                    graph_rgb <= info_section_color; 
                elsif missile_on = '1' then
                    graph_rgb <= missile_color; 
                elsif alien_missile_on = '1' then
                    graph_rgb <= missile_color;
                elsif alien_1_on = '1' then
                    graph_rgb <= alien_color; 
                elsif spaceship_on = '1' then
                    graph_rgb <= spaceship_color; 
                elsif asteroids_on = '1' then
                    graph_rgb <= multiasteroid_color ; 
                elsif asteroid_on = '1' then
                    graph_rgb <= asteroid_color; 
                else
                    graph_rgb <= "000"; 
                end if;
            end if;
        else
            graph_rgb <= "000"; 
        end if;
    end process;

end asteroid_arch;