clc
clear
close all

% initialize game engine
SPRITE_HEIGHT_PX = 16;
SPRITE_WIDTH_PX = 12;
SCALE = 1;
BACKGROUND_COLOR = [10, 50, 10];
SGE = simpleGameEngine("ascii-shrunk.png", SPRITE_HEIGHT_PX, ...
                       SPRITE_WIDTH_PX, SCALE, BACKGROUND_COLOR); 

% initialize sheet data
DATA = SheetData();

% parameters
ROW_CT = 10;
ROW_LABEL_WIDTH = 3;
COL_CT = 7;
CELL_WIDTH = 9;

HEADER_HEIGHT = 5;

% header buttons
ROW_1_BUTTONS = {'Save As','Load','New','Exit'};
ROW_2_BUTTONS = {'Copy','Paste'};

% size of screen
HEIGHT = ROW_CT * 2 + 7;
WIDTH = COL_CT * (CELL_WIDTH + 1) + ROW_LABEL_WIDTH + 2;

screen = zeros(HEIGHT, WIDTH) + ' ';

% create vertical borders
for i=1:HEIGHT
    screen(i, 1) = 0;
    screen(i, 1 + ROW_LABEL_WIDTH + 1) = 0;
    screen(i, WIDTH) = 0;
end

% create bottom border
for i=1:WIDTH
    screen(HEIGHT, i) = 0;
end

TOP_LEFT_Y_POS = HEADER_HEIGHT + 3;
TOP_LEFT_X_POS = ROW_LABEL_WIDTH + 3;

% for scrolling capabilities
top_left_row = 1;
top_left_col = 1;

% design screen
screen(1:HEADER_HEIGHT, 1:WIDTH) ...
    = buildHeader(WIDTH, ROW_1_BUTTONS, ROW_2_BUTTONS);
screen(TOP_LEFT_Y_POS:HEIGHT, TOP_LEFT_X_POS:WIDTH) ...
    = buildCellBorders(ROW_CT, COL_CT, CELL_WIDTH);
screen(HEADER_HEIGHT + 2:HEIGHT - 1, 2:2 + ROW_LABEL_WIDTH - 1) ...
    = buildRowLabels(ROW_CT, ROW_LABEL_WIDTH, top_left_row);
screen(HEADER_HEIGHT + 1:HEADER_HEIGHT + 2, ...
       1 + ROW_LABEL_WIDTH + 2:WIDTH - 1) ...
    = buildColLabels(COL_CT, CELL_WIDTH, top_left_col);

exit_clicked = false;
while ~exit_clicked
    screen(TOP_LEFT_Y_POS:HEIGHT, TOP_LEFT_X_POS:WIDTH) ...
        = buildCells(ROW_CT, COL_CT, CELL_WIDTH, ...
                     top_left_row, top_left_col, DATA);
    screen = buildBorders(screen, HEIGHT, WIDTH);
    SGE.drawScene(screen);
    [row, col, button] = SGE.getMouseInput();
    button_clicked = getHeaderButton(row, col, ROW_1_BUTTONS, ...
                                       ROW_2_BUTTONS);
    if isempty(button_clicked)
        if row <= HEADER_HEIGHT
            % test if it's a directional
            dir = '';
            if row == 2 && col == WIDTH - 4
                % up
                if top_left_row > 1
                    top_left_row = top_left_row - 1;
                    screen(HEADER_HEIGHT + 2:HEIGHT - 1, ...
                           2:2 + ROW_LABEL_WIDTH - 1) ...
                        = buildRowLabels(ROW_CT, ROW_LABEL_WIDTH, ...
                                         top_left_row);
                end
            elseif row ==  4 && col == WIDTH - 6
                % left
                if top_left_col > 1
                    top_left_col = top_left_col - 1;
                    screen(HEADER_HEIGHT + 1:HEADER_HEIGHT + 2, ...
                           1 + ROW_LABEL_WIDTH + 2:WIDTH - 1) ...
                        = buildColLabels(COL_CT, CELL_WIDTH, ...
                                         top_left_col);
                end
            elseif row ==  4 && col == WIDTH - 4
                % down
                top_left_row = top_left_row + 1;
                screen(HEADER_HEIGHT + 2:HEIGHT - 1, ...
                       2:2 + ROW_LABEL_WIDTH - 1) ...
                    = buildRowLabels(ROW_CT, ROW_LABEL_WIDTH, ...
                                     top_left_row);
            elseif row ==  4 && col == WIDTH - 2
                % right
                top_left_col = top_left_col + 1;
                screen(HEADER_HEIGHT + 1:HEADER_HEIGHT + 2, ...
                       1 + ROW_LABEL_WIDTH + 2:WIDTH - 1) ...
                    = buildColLabels(COL_CT, CELL_WIDTH, top_left_col);
            end
        else
            % test if it's a cell
            [cell_row, cell_col] = getCellPos(row, col, TOP_LEFT_Y_POS, ...
                                              TOP_LEFT_X_POS, CELL_WIDTH);

            if cell_row ~= 0 && cell_col ~= 0
                cell_row = cell_row + top_left_row - 1;
                cell_col = cell_col + top_left_col - 1;
                old_value = DATA.getCellValue(cell_row, cell_col);
                if isnumeric(old_value)
                    old_value = num2str(old_value);
                end
                input_str = getInput(SGE, screen, 'Value', old_value, WIDTH);
                DATA.setCellValue(cell_row, cell_col, input_str);
            end
        end
    else
        if strcmp(button_clicked, 'Exit') == 1
            exit_clicked = true;
            close(SGE.my_figure);
        elseif strcmp(button_clicked, 'Save As') == 1
            input_str = getInput(SGE, screen, 'File name', '', WIDTH);
            if ~isempty(input_str)
                DATA.toCSV(input_str);
            end
        elseif strcmp(button_clicked, 'Load') == 1
            input_str = getInput(SGE, screen, 'File name', '', WIDTH);
            if ~isempty(input_str)
                DATA.fromCSV(input_str);
            end
        elseif strcmp(button_clicked, 'New') == 1
            DATA.reset();
            top_left_row = 1;
            top_left_col = 1;
            screen(HEADER_HEIGHT + 2:HEIGHT - 1, ...
                   2:2 + ROW_LABEL_WIDTH - 1) ...
                = buildRowLabels(ROW_CT, ROW_LABEL_WIDTH, ...
                                 top_left_row);
            screen(HEADER_HEIGHT + 1:HEADER_HEIGHT + 2, ...
                   1 + ROW_LABEL_WIDTH + 2:WIDTH - 1) ...
                = buildColLabels(COL_CT, CELL_WIDTH, top_left_col);
        elseif strcmp(button_clicked, 'Copy') == 1
            [cell_row, cell_col] = selectCell(SGE, TOP_LEFT_Y_POS, ...
                                              TOP_LEFT_X_POS, CELL_WIDTH);
            clipboard('copy', DATA.getCellValue(cell_row, cell_col));
        elseif strcmp(button_clicked, 'Paste') == 1
            [cell_row, cell_col] = selectCell(SGE, TOP_LEFT_Y_POS, ...
                                              TOP_LEFT_X_POS, CELL_WIDTH);
            DATA.setCellValue(cell_row, cell_col, clipboard('paste'));
        end

    end
end

function [cell_row, cell_col] = selectCell(sge, top_left_y_pos, ...
                                           top_left_x_pos, cell_width)
    % Force user to select a cell and return its position.
    %
    % Input:
    %   1. the SGE object
    %   2. the y offset of the top left character
    %   3. the x offset of the top left character
    %   4. the width of a cell

    cell_row = 0;
    cell_col = 0;
    while cell_row == 0 && cell_col == 0
        [row, col, button] = sge.getMouseInput();
        [cell_row, cell_col] = getCellPos(row, col, top_left_y_pos, ...
                                          top_left_x_pos, cell_width);
    end
end

function [cell_row, cell_col] = getCellPos(row, col, top_left_y_pos, ...
                                           top_left_x_pos, cell_width)
    % Get the cell row and column clicked from the cursor position
    %
    % Input:
    %   1. the row of the character clicked
    %   2. the row of the character clicked
    %   3. the y offset of the top left character
    %   4. the x offset of the top left character
    %   5. the width of a cell
                                         
    cell_row = 0;
    cell_col = 0;

    if mod(row - top_left_y_pos, 2) == 0 ...
        && mod(col - top_left_x_pos, cell_width + 1) ~= cell_width ...
        && row >= top_left_y_pos && col >= top_left_x_pos

        cell_row = (row - top_left_y_pos) / 2 + 1;
        cell_col = floor((col - top_left_x_pos) ...
                         / (cell_width + 1)) + 1;
    end
end

function input_str = getInput(sge, screen, prompt, default, width)
    % Get input from the user. Return `default`
    % if the user presses `esc`.
    %
    % Input:
    %   1. the SGE object
    %   2. the previous screen
    %   3. the prompt to give the user
    %   4. the width of the screen

    printTextBox(sge, screen, [prompt ': ' default], width);
    key = ' ';
    input_str = default;
    while strcmp(key, 'return') ~= 1 && strcmp(key, 'escape') ~= 1
        key = getKey(sge);
        if length(key) == 1
            input_str = [input_str key];
        elseif strcmp(key, 'backspace') == 1
            input_str = input_str(1:end-1);
        end
        printTextBox(sge, screen, [prompt ': ' input_str], width);
    end
    if strcmp(key, 'escape')
        input_str = default;
    end
end

function printTextBox(sge, screen, contents, width)
    % Print a text box to replace the top buttons
    %
    % Input:
    %   1. the SGE object
    %   2. the previous screen
    %   3. the contents to print
    %   4. the width of the screen

    TEXT_BOX_HEIGHT = 5;

    screen(3, 1) = 0;
    screen(3, 2) = ' ';
    screen(3, width) = 0;
    screen(3, width - 1) = ' ';

    contents_idx = 1;

    for i=2:4
        for j=3:width-2
            if contents_idx <= length(contents)
                screen(i, j) = contents(contents_idx);
                contents_idx = contents_idx + 1;
            else
                screen(i, j) = ' ';
            end
        end
    end
    screen = buildBorders(screen, TEXT_BOX_HEIGHT, width);
    sge.drawScene(screen);
end

function key = getKey(sge)
    % Get keyboard input from SGE as a character, rather than character name.
    %
    % Input:
    %   1. the SGE object

    SYMBOL_NAMES = {'space', 'comma', 'period', 'semicolon', 'quote',...
        'slash', 'hyphen', 'leftbracket', 'rightbracket', 'equal',...
        'backquote', 'backslash','tab'};
    SYMBOL_VALUES = {' ', ',','.',';','''','/','-','[',']','=','`','\',sprintf('\t')};
    symblify = dictionary(SYMBOL_NAMES, SYMBOL_VALUES);

    key = getKeyboardInput(sge);
    if ismember(key, SYMBOL_NAMES)
        key = symblify({key});
    end
    key = processShift(key, sge.my_figure);
end

function key = processShift(key, fig)
    % Apply shift key, if pressed.    
    %
    % Input: 
    %   1. the key pressed
    %   2. the figure for the SGE object
    % Output: 
    %   key - the modified key
    %

    modifiers = get(fig, 'CurrentModifier');
    LOWERCASE_VALUES = {
        '1','2','3','4','5',...
        '6','7','8','9','0',...
        ';','''','/','-','[',...
        ']','=','á','é','í',...
        'ó','ú','ñ','ü','`',...
        '\',',','.','þ','ð',...
        'ġ','ċ',
    };
    UPPERCASE_VALUES = {
        '!','@','#','$','%',...
        '^','&','*','(',')',...
        ':','"','?','_','{',...
        '}','+','Á','É','Í',...
        'Ó','Ú','Ñ','Ü','~',...
        '|','<','>','Þ','Ð',...
        'Ġ','Ċ',
    };
    key = char(key);
    if ismember('shift',modifiers)
        if ismember(key, LOWERCASE_VALUES)
            dict = dictionary(LOWERCASE_VALUES, UPPERCASE_VALUES);
            key = dict({key});
        elseif isscalar(key) && key <= 'z' && key >= 'a'
            key = key + 'A' - 'a';
        end
    end
    key = char(key);
end

function button = getHeaderButton(row, col, row_1_buttons, row_2_buttons)
    % Get header button at (row, col) as a character array,
    % or return empty character array if header button not clicked.
    % 
    % Input:
    %   1. row
    %   2. column
    % Output:
    %   button - button at specified position

    ROW_1 = 2;
    ROW_2 = 4;

    button = '';

    if row == ROW_1
        row_buttons = row_1_buttons;
    elseif row == ROW_2
        row_buttons = row_2_buttons;
    else
        row_buttons = {};
    end
    
    i = length([0 ' ']) + 1;
    for row_button=row_buttons
        for c=row_button{1}
            if i == col
                button = row_button{1};
            end
            i = i + 1;
        end
        i = i + length([' ' 0 ' ']);
    end
end

function col_labels = buildColLabels(col_ct, cell_width, top_left_col)
    % Build labels for columns.
    % 
    % Input:
    %   1. # of columns
    %   2. width of the interior of a cell
    %   3. col index of top left column
    % Output:
    %   col_labels - labels for columns with a row below underlining it

    width = col_ct * (cell_width + 1)  - 1;
    col_labels = zeros(2, width) + ' ';

    col = top_left_col;
    for col_off=1:col_ct
        col_label = colToLabel(col);
        label_start = (col_off - 1) * (cell_width + 1) ...
                      + ceil(cell_width / 2 - length(col_label) / 2) + 1;
        col_labels(1, label_start:label_start + length(col_label) - 1) ...
            = col_label;
        col = col + 1;
    end

    for i=1:width
        col_labels(2, i) = 0;
    end
end

function col_label = colToLabel(col)
    % Get column label from a col.
    % 
    % Input:
    %   1. column index to convert
    % Output:
    %   col_label - label of column

    col_label = '';
    while col > 0
        col_label = [('A' + mod(col - 1, 26)) col_label];
        col = floor((col - 1) / 26);
    end
    
end

function row_labels = buildRowLabels(row_ct, row_label_width, top_left_row)
    % Build labels for rows.
    % 
    % Input:
    %   1. # of rows
    %   2. width to allocate for a row label
    %   3. row idx of top left row
    % Output:
    %   row_labels - labels for rows

    row_labels = zeros(row_ct * 2, row_label_width) + ' ';
    fmt = sprintf('%%%dd', row_label_width);
    for row_off=1:row_ct
        row_labels(row_off * 2,1:row_label_width) ...
            = sprintf(fmt, top_left_row + row_off - 1);
    end
end

function cells = buildCells(row_ct, col_ct, cell_width, ...
                            top_left_row, top_left_col, data)
    % Build character matrix for cells.
    % 
    % Input:
    %   1. # of rows
    %   2. # of columns
    %   3. width of the interior of a cell
    %   4. row idx of top left cell
    %   5. col idx of top left cell
    % Output:
    %   cells - character matrix of cells

    cells = buildCellBorders(row_ct, col_ct, cell_width);
    for row=1:row_ct
        for col=1:col_ct
            col_off = (cell_width + 1) * (col - 1) + 1;
            row_idx = top_left_row + row - 1;
            col_idx = top_left_col + col - 1;
            cells(row * 2 - 1, col_off:col_off + cell_width - 1) ...
                = data.getCellStr(row_idx, col_idx, cell_width);
        end
    end

end

function cells = buildCellBorders(row_ct, col_ct, cell_width)
    % Build character matrix for cell borders.
    % 
    % Input:
    %   1. # of rows
    %   2. # of columns
    %   3. width of the interior of a cell
    % Output:
    %   cells - character matrix of cells

    height = row_ct * 2;
    width = col_ct * (cell_width + 1);
    cells = zeros(height, width) + ' ';
    for i=1:row_ct
        for j=1:width-1
            cells(2 * i, j) = 0;
        end
        if i == row_ct
            cells(2 * i, width) = 0;
        else
            cells(2 * i, width) = 0;
        end
    end

    for i=1:row_ct
        for j=1:col_ct
            cells(2 * i - 1, j * (cell_width + 1)) = 0;
        end
    end
end

function header = buildHeader(width, row_1_buttons, row_2_buttons)
    % Build character matrix for top header.
    % 
    % Input:
    %   1. width of screen
    %   2. cell array of character array of row 1 buttons
    %   3. cell array of character array of row 2 buttons
    % Output:
    %   header - header character matrix

    header = zeros(5, width) + ' ';
    for i=1:width
        header(1, i) = 0;
        header(3, i) = 0;
        header(5, i) = 0;
    end

    header(2, 1:width) = buildButtonHeader(width, row_1_buttons);
    header(4, 1:width) = buildButtonHeader(width, row_2_buttons);

    header(2, end - length(['^   ' 0]) + 1:end) = ['^   ' 0];
    header(4, end - length(['< v > ' 0]) + 1:end) = ['< v > ' 0];
end

function button_header = buildButtonHeader(width, buttons)
    % Build character array for buttons.
    % 
    % Input:
    %   1. width of screen
    %   2. cell array of character array of button names.
    % Output:
    %   button_header - button header character array

    button_header = zeros(1, width) + ' ';
    button_header(1:2) = [0 ' '];
    i = length([0 ' ']) + 1;
    for button=buttons
        for c=button{1}
            button_header(i) = c;
            i = i + 1;
        end
        button_header(i:i+length([' ' 0 ' '])-1) = [' ' 0 ' '];
        i = i + length([' ' 0 ' ']);
    end
end

function screen = buildBorders(old_screen, height, width)
    % Consider all `0`s to be a border, and replace them with border
    % sprites.
    %
    % Input:
    %   1. the original screen
    %   2. width of the screen
    %   3. height of the screen
    %
    % Output:
    %   screen - the updated screen

    screen = old_screen;

    for row=1:height
        for col=1:width
            if isBorder(old_screen(row, col))
                code = '';
                if row > 1 && isBorder(old_screen(row - 1, col))
                    code = [code 't'];
                end
                if col < width && isBorder(old_screen(row, col + 1))
                    code = [code 'r'];
                end
                if row < height && isBorder(old_screen(row + 1, col))
                    code = [code 'b'];
                end
                if col > 1 && isBorder(old_screen(row, col - 1))
                    code = [code 'l'];
                end
                screen(row, col) = getBar(code);
            end
        end
    end

end

function bar = getBar(code)
    % Get the sprite ID for a bar based on a code.
    % The code contains lowercase letters for the sides it touches,
    % as follows:
    % (t)op, (r)ight, (b)ottom, (l)eft in that order
    %
    % Input:
    %   1. the code to input
    % Output:
    %   bar - the sprite ID

    assert(~isempty(code))

    BAR_TB = 3;
    BAR_RL = 4;
    BAR_TRBL = 5;
    BAR_TL = 6;
    BAR_BL = 7;
    BAR_RB = 8;
    BAR_TR = 9;
    BAR_RBL = 10;
    BAR_TRL = 11;
    BAR_TBL = 13;
    BAR_TRB = 14;

    if strcmp(code, 'tb') == 1 || strcmp(code, 't') == 1
        bar = BAR_TB;
    elseif strcmp(code, 'rl') == 1
        bar = BAR_RL;
    elseif strcmp(code, 'trbl') == 1
        bar = BAR_TRBL;
    elseif strcmp(code, 'tl') == 1
        bar = BAR_TL;
    elseif strcmp(code, 'bl') == 1
        bar = BAR_BL;
    elseif strcmp(code, 'rb') == 1
        bar = BAR_RB;
    elseif strcmp(code, 'tr') == 1
        bar = BAR_TR;
    elseif strcmp(code, 'rbl') == 1
        bar = BAR_RBL;
    elseif strcmp(code, 'trl') == 1
        bar = BAR_TRL;
    elseif strcmp(code, 'tbl') == 1
        bar = BAR_TBL;
    elseif strcmp(code, 'trb') == 1
        bar = BAR_TRB;
    end
end

function is_border = isBorder(char)
    % Determine if a character represents a border.
    % All border sprites are borders, as well as `0`.
    %
    % Input:
    %   1. the character to test
    % Output:
    %   is_border - true iff `char` is a border
    
    BAR_TB = 3;
    BAR_RL = 4;
    BAR_TRBL = 5;
    BAR_TL = 6;
    BAR_BL = 7;
    BAR_RB = 8;
    BAR_TR = 9;
    BAR_RBL = 10;
    BAR_TRL = 11;
    BAR_TBL = 13;
    BAR_TRB = 14;

    is_border = char == 0 || char == BAR_TB || char == BAR_RL ...
             || char == BAR_TRBL || char == BAR_TL || char == BAR_BL ...
             || char == BAR_RB || char == BAR_TR || char == BAR_RBL ...
             || char == BAR_TRL || char == BAR_TBL || char == BAR_TRB;
end
