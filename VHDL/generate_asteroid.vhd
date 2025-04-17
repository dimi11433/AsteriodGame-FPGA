library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity asteroid_gen is 
    port(
        clk, reset: in std_logic;
        pixel_tick : in std_logic;
        video_on : in std_logic;
        spaceship_on: in std_logic;
        pixel_x : in std_logic_vector(9 downto 0);
        pixel_y : in std_logic_vector(9 downto 0);
        refresh_screen: in std_logic;
        asteroid_on_certainly: out std_logic
    );


end asteroid_gen; 

architecture asteroids of asteroid_gen is
    constant SCREEN_WIDTH : integer := 640;
    constant SCREEN_HEIGHT : integer := 480;

    type size_array_t is array(0 to 3) of integer;
    constant ASTEROID_SIZE : size_array_t := (
      0 => 10,
      1 => 15,
      2 => 20,
      3 => 25
    );


    constant ASTEROID_DY : integer := 1;
    constant ASTEROID_DX : integer := 1;

    

    signal pix_x, pix_y : unsigned(9 downto 0);

    signal asteroid_rom_bit : std_logic_vector(3 downto 0);

    type asteroid_id is record 
        asteroid_x_start : unsigned(9 downto 0);
        asteroid_x_end : unsigned(9 downto 0);
        asteroid_y_top : unsigned(9 downto 0);
        asteroid_y_bottom : unsigned(9 downto 0);
    end record asteroid_id;

    type asteroid_mov is record
        asteroid_x_start_next : unsigned(9 downto 0);
        asteroid_y_top_next : unsigned(9 downto 0);
    end record asteroid_mov;

    --we create an array of records which store the asteroids size aka ID
    type  asteroid_id_arry_t is array (0 to 3) of asteroid_id;
    --create an array of records which store the movements of each asteroid
    type asteroid_mov_arry_t is array (0 to 3) of asteroid_mov;
    
    
    signal asteroid_id_arry : asteroid_id_arry_t ;
    signal asteroid_mov_arry : asteroid_mov_arry_t;
    
    signal asteroid_on : std_logic_vector(3 downto 0);

    signal asteroid_colour : std_logic_vector(2 downto 0);

    -- signal refresh_screen : std_logic;

    signal collision_with_asteroid : std_logic;

    signal collision_with_asteroid_happened : std_logic;
    
    --asteroid image
    type rom_type_10 is array(0 to 9) of std_logic_vector(0 to 9);
    constant ASTEROID_ROM_1 : rom_type_10 := (
        "0011111100",
        "0111111110",
        "1111111111",
        "1111111111",
        "1111111111",
        "1111111111",
        "1111111111",
        "1111111111",
        "0111111110",
        "0011111100"
    );

    type rom_type_15 is array(0 to 14) of std_logic_vector(0 to 14);
    constant ASTEROID_ROM_2 : rom_type_15 := (
        "000111111100000",
        "001111111110000",
        "011111111111000",
        "011111111111000",
        "111111111111100",
        "111111111111100",
        "111111111111100",
        "111111111111100",
        "111111111111100",
        "111111111111100",
        "111111111111100",
        "011111111111000",
        "011111111111000",
        "001111111110000",
        "000111111100000"

    );

    type rom_type_20 is array(0 to 19) of std_logic_vector(0 to 19);
    constant ASTEROID_ROM_3 : rom_type_20 := (  
        "00011111111110000000", 
        "00111111111111000000",  
        "01111111111111100000",  
        "01111111111111100000",  
        "11111111111111110000",  
        "11111111111111110000",  
        "11111111111111110000",  
        "11111111111111110000",  
        "11111111111111110000",  
        "11111111111111110000",  
        "11111111111111110000",  
        "11111111111111110000",  
        "11111111111111110000",  
        "01111111111111100000",  
        "01111111111111100000",  
        "00111111111111000000",  
        "00011111111110000000",  
        "00001111111100000000",  
        "00000111111000000000",
        "00000000000000000000"
    );
    type rom_type_25 is array(0 to 24) of std_logic_vector(0 to 24);
    constant ASTEROID_ROM_4 : rom_type_25 :=(
        "0000011111111110000000000",  
        "0000111111111111000000000",  
        "0001111111111111100000000",  
        "0011111111111111110000000",  
        "0111111111111111111000000",  
        "0111111111111111111000000",  
        "1111111111111111111100000",  
        "1111111111111111111100000",  
        "1111111111111111111100000",  
        "1111111111111111111100000",  
        "1111111111111111111100000",  
        "1111111111111111111100000",  
        "1111111111111111111100000",  
        "1111111111111111111100000",  
        "1111111111111111111100000",  
        "1111111111111111111100000",  
        "1111111111111111111100000",  
        "0111111111111111111000000",  
        "0111111111111111111000000",  
        "0011111111111111110000000",  
        "0001111111111111100000000",  
        "0000111111111111000000000",  
        "0000011111111110000000000", 
        "0000001111111100000000000",  
        "0000000111111000000000000"
    );
begin
    pix_x <= unsigned(pixel_x);
    pix_y <= unsigned(pixel_y);

    asteroid_colour <= "111"; -- white/greyish 

    --Is the bit we are at the same bit in any of the asteroids.
    process(pix_y, pix_x)
    begin 
        for i in 0 to 3 loop 
            asteroid_rom_bit(i) <= ASTEROID_ROM_1(to_integer(pix_y) - to_integer(asteroid_id_arry(i).asteroid_y_top))
            (to_integer(pix_x) - to_integer(asteroid_id_arry(i).asteroid_x_start));

        end loop;
    end process;

    process(pix_x, pix_y)
    begin
        for i in 0 to 3 loop
            if (pix_x >= asteroid_id_arry(i).asteroid_x_start and
                pix_x <= asteroid_id_arry(i).asteroid_x_end   and
                pix_y >= asteroid_id_arry(i).asteroid_y_top   and
                pix_y <= asteroid_id_arry(i).asteroid_y_bottom and
                    asteroid_rom_bit(i) = '1')
            then
              asteroid_on(i) <= '1';
            else
              asteroid_on(i) <= '0';
            end if;

            if (asteroid_on(i) = '1') then
                asteroid_on_certainly <= '1';
            else
                asteroid_on_certainly <= '0';
            end if;
        end loop;
    end process;

    process(pix_x, pix_y)
    begin
        for i in 0 to 3 loop
            asteroid_id_arry(i).asteroid_x_end <= asteroid_id_arry(i).asteroid_x_start + ASTEROID_SIZE(i) - 1;
            asteroid_id_arry(i).asteroid_y_bottom <= asteroid_id_arry(i).asteroid_y_top + ASTEROID_SIZE(i) - 1; 
        end loop;
    end process; 

    -- refresh_screen <= '1' when (pix_x = to_unsigned(SCREEN_WIDTH - 1, 10) and
    --     pix_y = to_unsigned(SCREEN_HEIGHT - 1, 10) and pixel_tick = '1') else
    --     '0';
    process(spaceship_on, asteroid_on)
    begin
        for i in 0 to 3 loop
            if(spaceship_on = '1' and asteroid_on(i) = '1')then
                collision_with_asteroid <= '1';
            end if;
        end loop;
    end process;

    --move the asteroids vertical position
    process (asteroid_id_arry(0).asteroid_y_top,asteroid_id_arry(1).asteroid_y_top, asteroid_id_arry(2).asteroid_y_top, asteroid_id_arry(3).asteroid_y_top)
    begin
        for i in 0 to 3 loop
            if asteroid_id_arry(i).asteroid_y_top < to_unsigned(SCREEN_HEIGHT - ASTEROID_SIZE(i), 10) then
                asteroid_mov_arry(i).asteroid_y_top_next <= asteroid_id_arry(i).asteroid_y_top + ASTEROID_DY;
            else
                asteroid_mov_arry(i).asteroid_y_top_next <= to_unsigned(0, 10);
            end if;    
        end loop;
    end process;
    --Lets come back to the Dx movements
    -- process(asteroid_on)
    -- begin
    --     for i in 0 to 3 loop
    --         if asteroid_on(0) = '1' and asteroid_on(1) = '1' 
    -- at reset, set the initial positions of the objects
    process (clk, reset)
    begin
        if reset = '1' then
            for i in 0 to 3 loop
                asteroid_id_arry(i).asteroid_x_start <= to_unsigned(SCREEN_WIDTH / 2 - ASTEROID_SIZE(i) / 2, 10);
                asteroid_id_arry(i).asteroid_y_top <= (others => '0');
                --number_of_lives <= "11"; -- 3 lives
            end loop;
        elsif rising_edge(clk) then
            if refresh_screen = '1' then
                for i in 0 to 3 loop
                    if collision_with_asteroid_happened = '1' then
                        asteroid_id_arry(i).asteroid_y_top <= to_unsigned(0, 10);
                        collision_with_asteroid_happened <= '0';
                    else
                        asteroid_id_arry(i).asteroid_y_top <= asteroid_mov_arry(i).asteroid_y_top_next;
                    end if;
                    
                end loop;
            end if;

            if collision_with_asteroid = '1' then
                collision_with_asteroid_happened <= '1';
            end if;
        end if;
    end process;

end asteroids;
