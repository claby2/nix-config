local M = {}

-- Review comments: quickfix list with one entry per chain of REVIEW comments.
-- Matches "REVIEW:", "REVIEW claude:", "REVIEW auggie:" after a comment leader.
-- A chain is a run of consecutive lines starting with the same comment leader
-- (e.g. `//`, `#`, `--`) as its first REVIEW line; only that first line is listed.
local review_rg = [[REVIEW( claude| auggie)?:]]

local function review_match(line)
	local s = line:find("REVIEW:", 1, true)
		or line:find("REVIEW claude:", 1, true)
		or line:find("REVIEW auggie:", 1, true)
	if not s then
		return nil
	end
	-- Comment leader = last whitespace-delimited token before REVIEW, must be pure punctuation.
	local leader = line:sub(1, s - 1):match("(%S+)%s*$")
	-- Reject alphanumerics and bare quotes/brackets/operators (e.g. `x = "REVIEW:`).
	if leader and not leader:find("%w") and not leader:find("^[\"'`()%[%]{}=,:]+$") then
		return leader
	end
end

local function review_chains(lines, filename)
	local items, leader = {}, nil
	for i, line in ipairs(lines) do
		if leader and vim.trim(line):sub(1, #leader) == leader then
			-- still inside the current chain
		else
			leader = nil
			local l = review_match(line)
			if l then
				leader = l
				table.insert(
					items,
					{ filename = filename, lnum = i, col = line:find("REVIEW", 1, true), text = vim.trim(line) }
				)
			end
		end
	end
	return items
end

M.quickfix = function()
	local files = {}
	local res = vim.system({ "rg", "--no-messages", "-l", "-e", review_rg }, { text = true, cwd = vim.fn.getcwd() })
		:wait()
	for f in (res.stdout or ""):gmatch("[^\n]+") do
		files[vim.fn.fnamemodify(f, ":p")] = true
	end
	-- Unsaved buffers may differ from disk, so include loaded file buffers too.
	for _, b in ipairs(vim.api.nvim_list_bufs()) do
		local name = vim.api.nvim_buf_get_name(b)
		if
			vim.api.nvim_buf_is_loaded(b)
			and vim.bo[b].buftype == ""
			and name ~= ""
			and not name:match("^%w[%w+.-]*://") -- skip virtual buffers, e.g. diffview://
		then
			files[name] = true
		end
	end

	local names = vim.tbl_keys(files)
	table.sort(names)
	local items = {}
	for _, name in ipairs(names) do
		local bufnr = vim.fn.bufnr(name)
		local lines
		if bufnr ~= -1 and vim.api.nvim_buf_is_loaded(bufnr) then
			lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
		else
			local ok, read = pcall(vim.fn.readfile, name)
			lines = ok and read or {}
		end
		vim.list_extend(items, review_chains(lines, name))
	end

	if #items == 0 then
		vim.notify("No REVIEW comments found", vim.log.levels.INFO)
		return
	end
	vim.fn.setqflist({}, " ", { title = "REVIEW comments", items = items })
	vim.cmd("copen")
end

return M
