library(ggplot2)
library(data.table)
library(dplyr)
library(tidyr)
library(ggrepel)

palette_fylke <- c(
  "Agder"            = "#332288",
  "Akershus"         = "#88CCEE",
  "Buskerud"         = "#44AA99",
  "Finnmark"         = "#117733",
  "Innlandet"        = "#999933",
  "Møre og Romsdal"  = "#DDCC77",
  "Nordland"         = "#CC6677",
  "Oslo"             = "#882255",
  "Rogaland"         = "#AA4499",
  "Telemark"         = "#661100",
  "Troms"            = "#6699CC",
  "Trøndelag"        = "#888888",
  "Vestfold"         = "#E69F00",
  "Vestland"         = "#56B4E9",
  "Østfold"          = "#009E73"
)

fylke_order <- names(palette_fylke)

# ---------------------------------------------------------
# 3. Prepare dataset 
# ---------------------------------------------------------
# Convert to data.table by reference (no full copy).
setDT(fn)

# Define the stacking order from bottom to top.
category_order <- c(
  "Agder"            ,
  "Akershus"         ,
  "Buskerud"         ,
  "Finnmark"         ,
  "Innlandet"        ,
  "Møre og Romsdal"  ,
  "Nordland"         ,
  "Oslo"             ,
  "Rogaland"         ,
  "Telemark"         ,
  "Troms"            ,
  "Trøndelag"        ,
  "Vestfold"         ,
  "Vestland"         ,
  "Østfold"          
)

# Set the factor levels to control stacking and label order.
fn[, fylke := factor(
  fylke,
  levels = category_order
)]

# Rename columns for consistency with the earlier ggplot code.
# This is optional; alternatively, keep Stofftype and antall.
setnames(
  fn,
  old = c("fylke", "antall"),
  new = c("category", "value")
)

# Validate the data.
stopifnot(
  is.numeric(fn$value),
  all(fn$value >= 0, na.rm = TRUE)
)

# ---------------------------------------------------------
# 4. Calculate label positions for the last year
# ---------------------------------------------------------

# Find the latest year in the dataset.
latest_year <- max(fn$year, na.rm = TRUE)

# Select observations for the final year and sort them
# according to the stacking order.
label_data <- fn[year == latest_year]
setorder(label_data, category)

# Calculate the centre of each area:
# cumulative = upper boundary of the stacked area
# label_y = centre of the area
label_data[, cumulative := cumsum(value)]

label_data[, label_y := cumulative - value / 2]

# Keep only categories with positive values.
label_data <- label_data[
  !is.na(value) & value > 0
]

# Convert factor labels to character for geom_text_repel().
label_data[, category := as.character(category)]

# ---------------------------------------------------------
# 4b. Create custom horizontal gridlines
# ---------------------------------------------------------

grid_df <- data.frame(
  y = seq(0, 400, by = 50),
  x_start = min(fn$year),
  x_end = latest_year
)

# ---------------------------------------------------------
# 5. Draw the stacked area chart
# ---------------------------------------------------------

p <- ggplot(
  fn,
  aes(
    x = year,
    y = value,
    fill = category,
    group = category
  )
) +
  # Draw horizontal gridlines only within the plotting area.
  # They stop at the final year and do not extend under labels.
  geom_segment(
    data = grid_df,
    aes(
      x = x_start,
      xend = x_end,
      y = y,
      yend = y
    ),
    inherit.aes = FALSE,
    colour = "#D9D9D9",
    linewidth = 0.4
  ) +
  geom_area(
    position = position_stack(reverse = TRUE)
    #     colour = "white",
#     linewidth = 0.3
  ) +
  # Direct labels replace the conventional legend.
  # Leader lines connect labels to their respective areas.
  geom_text_repel(
    data = label_data,
    aes(
      x = year,
      y = label_y,
      label = category
    ),
    inherit.aes = FALSE,
    force = 2,
    nudge_x = 1.3,
    direction = "y",
    hjust = 0,
    size = 5.5, #text size
    colour = "#222222",
    segment.colour = "#555555",
    segment.size = 0.35,
    box.padding = 0.35,
    point.padding = 0.2,
    max.overlaps = Inf,
    min.segment.length = 0,
    seed = 123
  ) +
  # Apply the palette to the stacked areas.
  # drop = FALSE keeps the colour mapping stable even if
  # a category is absent in a particular subset of the data.
  scale_fill_manual(
    values = palette_fylke,
    breaks = category_order,
    drop = FALSE
  ) +
  # Leave room on the right for the direct labels.
  scale_x_continuous(
    breaks = seq(
      min(fn$year),
      max(fn$year),
      by = 1
    ),
    expand = expansion(mult = c(0.005, 0.35))
  ) +
  scale_y_continuous(
    limits = c(0, 400),
    breaks = seq(0, 400, by = 50),
    expand = expansion(mult = c(0, 0.02))
  ) +
  # Preserve the original scale and allow labels outside
  # the panel without clipping them.
  coord_cartesian(clip = "off") +
  # Clear axis labels and a restrained grid.
  labs(
    title = "",
    x = NULL,
    y = "Antall narkotikautløste dødsfall",
    fill = NULL,
    caption = paste(
      "Datakilde:",
      "Dødsårsaksregisteret, Folkehelseinstituttet"
    )
  ) +
  # Remove the legend because each area is labelled.
  guides(fill = "none") +
  # A white background and light horizontal gridlines
  # improve readability in reports and print.
  theme_minimal(base_size = 18) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 15,
      colour = "#222222"
    ),
    axis.title.y = element_text(
      colour = "#333333",
      margin = margin(r = 10)
    ),
    axis.text = element_text(
      colour = "#444444",
      angle = 90,
      hjust = 1,
      vjust = 0.5
    ),
    panel.grid.major.y = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "none",
    plot.margin = margin(
      t = 12, r = 120, b = 12, l = 12
    ),
    plot.caption = element_text(
      size = 12,
      colour = "#333333",
      hjust = 1 #right align = 1 and left align = 0
    )
  )

# Display the chart.
print(p)


# ---------------------------------------------------------
# 6. Export a high-resolution figure
# ---------------------------------------------------------

# A wider output gives the direct labels enough room.
# Use a larger width than the original plot to prevent
# labels from being crowded or cut off.

ggsave(
  filename = "fylke_antall_dor.png",
  plot = p,
  width = 14,
  height = 8,
  units = "in",
  dpi = 300,
  bg = "white"
)
