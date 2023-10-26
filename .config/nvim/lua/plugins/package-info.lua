local M = {
  "vuki656/package-info.nvim",
  dependencies = "MunifTanjim/nui.nvim",
}

function M.config()
  require("package-info").setup({
    package_manager = "npm",
    hide_unstable_versions = true,
  })

  -- Show dependency versions
  vim.api.nvim_set_keymap(
    "n",
    "<LEADER>ns",
    "<cmd>lua require('package-info').show({force = true})<cr>",
    { silent = true, noremap = true, desc = "show" }
  )

  -- Hide dependency versions
  vim.api.nvim_set_keymap(
    "n",
    "<LEADER>nc",
    "<cmd>lua require('package-info').hide()<cr>",
    { silent = true, noremap = true, desc = "hide" }
  )

  -- Toggle dependency versions
  vim.api.nvim_set_keymap(
    "n",
    '<LEADER>nt',
    "<cmd>lua require('package-info').toggle()<cr>",
    { silent = true, noremap = true, desc = 'toggle' }
  )

  -- Update dependency on the line
  vim.api.nvim_set_keymap(
    'n',
    '<LEADER>nu',
    "<cmd>lua require('package-info').update()<cr>",
    { silent = true, noremap = true, desc = 'update' }
  )

  -- Delete dependency on the line
  vim.api.nvim_set_keymap(
    'n',
    '<LEADER>nd',
    "<cmd>lua require('package-info').delete()<cr>",
    { silent = true, noremap = true, desc = 'delete' }
  )

  -- Install a new dependency
  vim.api.nvim_set_keymap(
    'n',
    '<LEADER>ni',
    "<cmd>lua require('package-info').install()<cr>",
    { silent = true, noremap = true, desc = 'install' }
  )

  -- Install a different dependency version
  vim.api.nvim_set_keymap(
    'n',
    '<LEADER>np', "<cmd>lua require('package-info').change_version()<cr>",
    { silent = true, noremap = true, desc = 'change version' }
  )

  require("telescope").setup({
    extensions = {
      package_info = {
        -- Optional theme (the extension doesn't set a default theme)
        theme = "ivy",
      },
    },
  })

  require("telescope").load_extension("package_info")
end

return M
