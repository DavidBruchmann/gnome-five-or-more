#five-or-more executable

five_or_more_sources = [
  'config.vapi',
  'accessibility-manager.vala',
  'accessibility-profile.vala',
  'board.vala',
  'board-dimension-manager.vala',
  'color-scheme.vala',
  'color-scheme-manager.vala',
  'combo-mode-indicator-manager.vala',
  'composite-line-effects.vala',
  'composite-score-display.vala',
  'composite-scoring.vala',
  'coordinate-validator.vala',
  'development-support.vala',
  'fallback-generator.vala',
  'game.vala',
  'game-constants.vala',
  'hybrid-loader.vala',
  'layered-renderer.vala',
  'line-detector.vala',
  'game-info-panel.vala',
  'player-statistics.vala',
  'statistics-panel.vala',
  'tabbed-sidebar.vala',
  'main.vala',
  'next-pieces-widget.vala',
  'piece.vala',
  'piece-generator.vala',
  'resource-validator.vala',
  'svg-theme-template.vala',
  'theme-renderer.vala',
  'unified-line-detector.vala',
  'view.vala',
  'window.vala',
  resources,
]

five_or_more_deps = [
  gee_dep,
  gio_dep,
  gtk_dep,
  json_glib_dep,
  libgnome_games_support_dep,
  librsvg_dep,
  libmath_dep,
]

five_or_more_vala_args = [
  '--gresources', resource_files,
]

executable('five-or-more', five_or_more_sources,
  dependencies: five_or_more_deps,
  vala_args: five_or_more_vala_args,
  install: true,
)
