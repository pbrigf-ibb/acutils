#' fetch ScanR result/export files
#'
#' Copy all ScanR result files, chosen parameter data files, and the screen log
#' into a single location.
#'
#' Given the location of a master directory, i.e. one where multiple scans are stored,
#' this function goes into all scan directories and locates all files in the
#' "PopulationData" subdirectory, as well as any "ParameterData" files that
#' contain an object name specified by a regular expression (\code{object}).
#' All files are copied to a specified directory.
#'
#' Names of scan directories, which are usually plate numebrs,
#' are added to all respective file names.
#'
#' If the master directory contains a file with a name matching the regex "screenlog",
#' it will also be copied.
#'
#' Sort the copied files as you wish.
#'
#' @param where.from directory where all screen data is stored;
#'                   defaults to current working directory,
#'                   otherwise must be an existing directory
#' @param where.to directory where all files will be copied;
#'                 defaults to current working directory,
#'                 otherwise may be any directory;
#'                 a non-existing one will be created
#' @param object regular expression that defines which ParameterData files to copy;
#'               defaults to Main as this is always present and usually is the only relevant one
#'
#' @export

fetch_files <- function(where.from, where.to, object = 'Main') {
  # remember current working directory and come back to it when all files are copied
  .home <- getwd()
  on.exit(setwd(.home))
  # check if directories exist
  if (missing(where.from)) where.from <- getwd()
  if (missing(where.to)) where.to <- getwd()
  if (!dir.exists(where.to)) dir.create(where.to)
  if (!endsWith(where.to, '/')) where.to <- paste0(where.to, '/')
  # go to master directory
  master <- where.from
  setwd(master)
  # check for and copy log file
  logfile <- list.files(pattern = 'screenlog')
  newpath <- paste0(where.to, logfile)
  file.copy(from = logfile, to = newpath)
  # get all scan directories
  dirs <- list.dirs(full.names = FALSE, recursive = FALSE)
  # do the deed
  for (d in dirs) {
    setwd(d);
    # prepare names for parameter data files
    newpath <- paste0(where.to, 'ParameterData_', object, '_', d,'.txt')
    file.copy(from = paste0('ParameterData_', object,'.txt'), to = newpath)
    if (dir.exists('Population Results')) {
      setwd('Population Results')
      files <- list.files()
      newpath <- paste0(where.to, d,'_', files)
      file.copy(from = files, to = newpath)
      setwd(master)
    } else {
      setwd(master)
      next
    }
  }
}
