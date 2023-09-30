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
  vim.keymap.set(
    { "n" }, "<LEADER>ns", require("package-info").show, { silent = true, noremap = true, desc = "show" }
  )

  -- Hide dependency versions
  vim.keymap.set(
    { "n" }, "<LEADER>nc", require("package-info").hide, { silent = true, noremap = true, desc = "hide" }
  )

  -- Toggle dependency versions
  vim.keymap.set(
    { "n" }, "<LEADER>nt", require("package-info").toggle, { silent = true, noremap = true, desc = "toggle" }
  )

  -- Update dependency on the line
  vim.keymap.set(
    { "n" }, "<LEADER>nu", require("package-info").update, { silent = true, noremap = true, desc = "update" }
  )

  -- Delete dependency on the line
  vim.keymap.set(
    { "n" }, "<LEADER>nd", require("package-info").delete, { silent = true, noremap = true, desc = "delete" }
  )

  -- Install a new dependency
  vim.keymap.set(
    { "n" }, "<LEADER>ni", require("package-info").install, { silent = true, noremap = true, desc = "install" }
  )

  -- Install a different dependency version
  vim.keymap.set(
    { "n" }, "<LEADER>np", require("package-info").change_version,
    { silent = true, noremap = true, desc = "change version" }
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
