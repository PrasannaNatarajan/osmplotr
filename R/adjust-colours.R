#' adjust_colours
#'
#' Adjusts a given colour by lightening or darkening it by the specified amount
#' (relative scale of -1 to 1).  Adjustments are made in RGB space, for
#' limitations of which see \code{?convertColor}
#'
#' @param cols A vector of \code{R} colours (for allowable formats of which, see
#' \code{?col2rgb}).
#' @param adj A number between -1 and 1 determining how much to lighten
#' (positive values) or darken (negative values) the colours.
#' @param plot If \code{TRUE}, generates a plot to allow visual comparison of
#' original and adjusted colours.
#' @return Corresponding vector of adjusted colours (as hexadecimal strings).
#' @export
#'
#' @seealso \code{\link{osm_structures}}, \code{?col2rgb}.
#' 
#' @examples
#' cols <- adjust_colours (cols=heat.colors (10), adj=-0.2, plot=TRUE)
#'
#' # 'adjust_colours' also offers an easy way to adjust the default colour
#' # schemes provided by 'osm_structures'. The following lines darken the
#' # highway colour of the 'light' colour scheme by 20%
#' structures <- osm_structures (structures=c('building', 'highway', 'park'),
#'                               col_scheme='light')
#' structures$cols [2] <- adjust_colours (structures$cols [2], adj=-0.2)
#' # Plot these structures:
#' bbox <- get_bbox (c (-0.13, 51.5, -0.11, 51.52))
#' \dontrun{
#' dat_B <- extract_osm_objects (value='building', bbox=bbox)
#' dat_H <- extract_osm_objects (value='highway', bbox=bbox)
#' dat_P <- extract_osm_objects (value='park', bbox=bbox)
#' }
#' # These data are also included in the 'london' data of 'osmplotr'
#' osm_data <- list (dat_B=london$dat_BNR, dat_H=london$dat_HP, dat_P=london$dat_P)
#' dat <- make_osm_map (structures=structures, osm_data=osm_data, bbox=bbox)
#' print_osm_map (dat$map)


adjust_colours <- function (cols, adj=0, plot=FALSE)
{
    # ---------------  sanity checks and warnings  ---------------
    # ---------- cols
    if (missing (cols)) stop ('cols must be provided')
    if (is.null (cols)) return (NULL)
    if (any (is.na (cols))) stop ('One or more cols is NA')
    tryCatch (
              col2rgb (cols),
              error = function (e) 
              {
                  e$message <-  paste0 ('Invalid colours: ', cols)
                  stop (e)
              })
    if (class (cols [1]) != 'matrix')
        cols <- col2rgb (cols)
    # ---------- adj
    if (is.null (adj)) return (NULL)
    else if (is.na (adj)) stop ('adj is NA')
    adj <- tryCatch (
                     as.numeric (adj),
                     warning = function (w) 
                     {
                         w$message <- 'adj can not be coerced to numeric'
                     })
    if (!is.numeric (adj)) stop (adj)
    if (adj < -1 | adj > 1)
        stop ('adj must be between -1 and 1')
    # ---------- plot
    if (is.null (plot)) return (NULL)
    else if (is.na (plot)) stop ('plot is NA')
    plot <- tryCatch (
                     as.logical (plot),
                     warning = function (w) 
                     {
                         w$message <- 'plot is not logical'
                     })
    if (!is.logical (plot)) stop (plot)
    if (is.na (plot)) stop ('plot can not be coerced to logical')
    # ---------------  end sanity checks and warnings  ---------------

    n <- ncol (cols)
    cols_old <- apply (cols, 2, function (x)
                       rgb (x[1], x[2], x[3], maxColorValue=255))

    if (adj > 0)
        cols <- cols + adj * (255 - cols)
    else
        cols <- cols + adj * cols
    cols <- apply (cols, 2, function (x)
                   rgb (x[1], x[2], x[3], maxColorValue=255))

    if (plot) {
        plot.new ()
        par (mar=rep (0, 4))
        plot (NULL, NULL, xlim=c(0, n), ylim=c (0, 2), xaxs='i', yaxs='i')
        for (i in seq (n))
        {
            rect (i-1, 1, i, 2, col=cols_old [i], border=NA)
            rect (i-1, 0, i, 1, col=cols [i], border=NA)
        }
        rect (0, 1.4, n, 1.6, col = rgb (1, 1, 1, 0.5), border = NA)
        text (n / 2, 1.5, labels = 'old')
        rect (0, 0.4, n, 0.6, col = rgb (1, 1, 1, 0.5), border = NA)
        text (n / 2, 0.5, labels = 'new')
    }

    return (cols)
} # end function colour.mat
