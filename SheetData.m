classdef SheetData < handle
    properties
        data;
    end

    methods
        function obj = SheetData()
            obj.data = {};
        end

        function reset(obj)
            % Reset the data in the sheet.

            obj.data = {};
        end

        function fromCSV(obj, csv_name)
            % Load the data from a csv file.
            %
            % Input:
            %   1. name of csv file

            obj.data = readmatrix(csv_name, 'OutputType', 'char');
            for i=1:size(obj.data, 1)
                for j=1:size(obj.data, 2)
                    num = str2double(obj.data{i, j});
                    if ~isnan(num)
                        obj.data{i, j} = num;
                    end
                end
            end
        end

        function toCSV(obj, csv_name)
            % Write data to a csv file.
            %
            % Input:
            %   1. name of csv file

            writecell(obj.data, csv_name)
        end
     
        function setCellValue(obj, row, col, value)
            % Set the contents of a cell.
            % 
            % Input:
            %   1. row index to set
            %   2. col index to set
            %   3. value to set cell to

            num = str2double(obj.data{row, col});
            if ~isnan(num)
                obj.data{row, col} = num;
            else
                obj.data{row, col} = value;
            end
        end

        function cell_value = getCellValue(obj, row, col)
            % Get the contents of a cell.
            %
            % Input:
            %   1. row index to get
            %   2. col index to get
            % Output:
            %   cell_value - value of cell

            assert(0 < row);
            assert(0 < col);

            if row <= size(obj.data, 1) && col <= size(obj.data, 2)
                cell_value = obj.data{row, col};
            else
                cell_value = '';
            end
        end

        function cell_str = getCellStr(obj, row, col, cell_width)
            % Get the displayed contents of a single cell.
            % 
            % Input:
            %   1. row index to sample.
            %   2. column index to sample.
            %   3. width of the interior of a cell
            % Output:
            %   cell_str - character array representing cell contents

            assert(0 < row);
            assert(0 < col);

            value = obj.getCellValue(row, col);

            if isnumeric(value)
                fmt = sprintf('%%%dd', cell_width);
            else
                fmt = sprintf('%%-%ds', cell_width);
            end
            value_str = sprintf(fmt, value);
            cell_str = value_str(1:cell_width);
        end
    end
end

