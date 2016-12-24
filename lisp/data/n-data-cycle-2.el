(setq n-data-cycle-2 (if (n-file-exists-p "$HOME/.snapshot/hourly.0")
                         (nfly-cycle-compose-dir-list
                          "$HOME/.snapshot/hourly.0/"
                          "$HOME/.snapshot/hourly.1/"
                          "$HOME/.snapshot/nightly.0/"
                          "$HOME/.snapshot/nightly.1/"
                          "$HOME/.snapshot/nightly.2/"
                          "$HOME/.snapshot/weekly.0/"
                          "$HOME/"
                          )
                       (nfly-cycle-compose-dir-list
                        "$HOME/"
                        "$BACKUP_DIR/incremental_saves/users/nsproul/"
                        "$BACKUP_DIR/users.latest/nsproul/"
                        "$BACKUP_DIR/users.2*/nsproul/"
                        )
                       )
      )
