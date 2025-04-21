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


    constant ASTEROID_DY : integer := 5;
    constant ASTEROID_DX : integer := 4;
    signal pix_x, pix_y : unsigned(9 downto 0);
    type asteroid_id is record 
        asteroid_x_start : unsigned(9 downto 0);
        asteroid_x_end : unsigned(9 downto 0);
        asteroid_y_top : unsigned(9 downto 0);
        asteroid_y_bottom : unsigned(9 downto 0);
    end record asteroid_id;

    --we create an array of records which store the asteroids size aka ID
    type  asteroid_id_arry_t is array (0 to 3) of asteroid_id;
    signal asteroid_id_arry : asteroid_id_arry_t ;
    -- signal asteroid_mov_arry : asteroid_mov_arry_t;
    signal rnd10 : std_logic_vector(9 downto 0);

    type next_asteroid_y_top_t is array (0 to 3) of unsigned(9 downto 0);
    signal next_asteroid_y_top : next_asteroid_y_top_t := (others => (others => '0'));
    -- signal next_asteroid_y_top : array (0 to 3) of unsigned(9 downto 0);
    signal asteroid_on : std_logic_vector(3 downto 0);

    signal asteroid_colour : std_logic_vector(2 downto 0);

    -- signal refresh_screen : std_logic;
    signal asteroid_in_asteroid : std_logic_vector(3 downto 0);

    signal asteroid_collision : std_logic_vector(3 downto 0); 
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
    lfsr10_unit : entity work.lfsr10
        port map(
            clk => clk,
            rst => reset,
            rnd => rnd10
        );




    pix_x <= unsigned(pixel_x);
    pix_y <= unsigned(pixel_y);

    asteroid_colour <= "111"; -- white/greyish 
    --Is the bit we are at the same bit in any of the asteroids.

    g_GENERATE_ROM: for ii in 0 to 3 generate
        process(pix_x, pix_y, asteroid_id_arry(ii))
            variable row, col : integer;
            variable bit_on : std_logic := '0';
            begin 
                asteroid_on(ii) <= '0'; --default
                --check bounds 
                if (pix_x >= asteroid_id_arry(ii).asteroid_x_start and
                pix_x <= asteroid_id_arry(ii).asteroid_x_end   and
                pix_y >= asteroid_id_arry(ii).asteroid_y_top   and
                pix_y <= asteroid_id_arry(ii).asteroid_y_bottom) then
                        
                        row := to_integer(pix_y) - to_integer(asteroid_id_arry(ii).asteroid_y_top);
                        col := to_integer(pix_x) - to_integer(asteroid_id_arry(ii).asteroid_x_start);

                        case ASTEROID_SIZE(ii) is
                            when 10 => bit_on := ASTEROID_ROM_1(row)(col);
                            when 15 => bit_on := ASTEROID_ROM_2(row)(col);
                            when 20 => bit_on := ASTEROID_ROM_3(row)(col);
                            when 25 => bit_on := ASTEROID_ROM_4(row)(col);
                            when others => bit_on := '0';
                        end case;

                        if (bit_on = '1' )then
                            asteroid_on(ii) <= '1';
                        end if;
                end if;
        end process;
    end generate g_GENERATE_ROM;

    g_GEN_COLL: for idx in 0 to 3 generate
        asteroid_collision(idx) <= '1' when (spaceship_on = '1' and asteroid_on(idx) = '1')
            else '0';
    end generate g_GEN_COLL;

    -- g_GEN_ASTCOLL: for ii in 0 to 3 generate
    --     process(asteroid_on(ii))
    --         begin
    --             asteroid_in_asteroid(ii) <= '1' when (asteroid_on())

        
    asteroid_on_certainly <=
        '1' when asteroid_on(0) = '1' or
                asteroid_on(1) = '1' or
                asteroid_on(2) = '1' or
                asteroid_on(3) = '1'
        else '0';

    --Changing the location update to a generate block 
    g_GENERATE_ID: for ii in 0 to 3 generate
        asteroid_id_arry(ii).asteroid_x_end <= asteroid_id_arry(ii).asteroid_x_start + to_unsigned(ASTEROID_SIZE(ii) - 1, 10);
        asteroid_id_arry(ii).asteroid_y_bottom <= asteroid_id_arry(ii).asteroid_y_top + to_unsigned(ASTEROID_SIZE(ii) - 1, 10);
    end generate g_GENERATE_ID;

    --move the asteroids vertical position
    g_GENERATE_movey: for idx in 0 to 3 generate
        process(asteroid_id_arry(idx).asteroid_y_top)
            begin
                if (asteroid_id_arry(idx).asteroid_y_top < to_unsigned(SCREEN_HEIGHT - ASTEROID_SIZE(idx), 10)) then
                    next_asteroid_y_top(idx) <= asteroid_id_arry(idx).asteroid_y_top + to_unsigned(ASTEROID_DY, 10);
                else
                    next_asteroid_y_top(idx) <= (others => '0');
                end if;
        end process;
    end generate g_GENERATE_movey;

   
    process (clk, reset)
    variable rnd_val : integer;
    variable base : integer;
    variable col_flag : std_logic_vector(3 downto 0);
    begin
        if reset = '1' then        
            for i in 0 to 3 loop
                base := to_integer(unsigned(rnd10));
                rnd_val := (base + i*123) mod (SCREEN_WIDTH - ASTEROID_SIZE(i) + 1);
                asteroid_id_arry(i).asteroid_x_start <= to_unsigned(rnd_val, 10);
                asteroid_id_arry(i).asteroid_y_top <= (others => '0');
                --number_of_lives <= "11"; -- 3 lives
            end loop;
        elsif(rising_edge(clk)) then
            if refresh_screen = '1' then
                for i in 0 to 3 loop
                    if col_flag(i) = '1' then
                        base := to_integer(unsigned(rnd10));
                        rnd_val := (base + i*123) mod (SCREEN_WIDTH - ASTEROID_SIZE(i) + 1);
                        asteroid_id_arry(i).asteroid_x_start <= to_unsigned(rnd_val, 10);
                        asteroid_id_arry(i).asteroid_y_top <= (others => '0');
                        col_flag(i) := '0'; 
                    else
                        base := to_integer(unsigned(rnd10));
                        rnd_val := (base + i*123) mod (SCREEN_WIDTH - ASTEROID_SIZE(i) + 1);
                        asteroid_id_arry(i).asteroid_x_start <= to_unsigned(rnd_val, 10);
                        asteroid_id_arry(i).asteroid_y_top <= next_asteroid_y_top(i);
                    end if;
                end loop;
                if(asteroid_collision(0) = '1')then
                    col_flag(0) := '1';
                end if;
                if(asteroid_collision(1) = '1')then
                    col_flag(1) := '1';
                end if;   
                if(asteroid_collision(2) = '1')then
                    col_flag(2) := '1';
                end if; 
                if(asteroid_collision(3) = '1')then
                    col_flag(3) := '1';
                end if;
                    
                    
            end if;
        end if;
    end process;

end asteroids;
