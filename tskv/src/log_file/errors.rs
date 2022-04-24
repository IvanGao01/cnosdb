use crate::file_manager;
use snafu;
use snafu::Snafu;

#[derive(Snafu, Debug)]
pub enum LogFileError {
    #[snafu(display("Error with write file : {}", source))]
    WriteFile {
        source: std::io::Error,
    },

    #[snafu(display("Error with read file : {}", source))]
    ReadFile {
        source: std::io::Error,
    },

    #[snafu(display("Error with open file : {}", source))]
    OpenFile {
        source: file_manager::FileError,
    },

    #[snafu(display("Error with sync file : {}", source))]
    SyncFile {
        source: std::io::Error,
    },

    #[snafu(display("Error with get file len : {}", source))]
    GetFileLen {
        source: std::io::Error,
    },

    EOF,

    InvalidPos,
}

pub type LogFileResult<T> = std::result::Result<T, LogFileError>;