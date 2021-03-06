
# == title
# class for a list of heatmaps
#
# == details
#
#          +------+
#          +------+
#          +------+
#    +-+-+-+------+-+-+-+
#    | | | |      | | | |
#    +-+-+-+------+-+-+-+
#          +------+
#          +------+
#          +------+
# 
HeatmapList = setClass("HeatmapList",
    slots = list(
        "ht_list" = "list",

        layout = "environment",
        gp_list = "list"
    ),
    prototype = list(
        ht_list = list(),
        layout = new.env(),
        gp_list = list()
    )
)

# == title
# Add heatmaps to the heatmap list
#
# == param
# -object a `HeatmapList` object.
# -ht a `Heatmap` object or a `HeatmapList` object.
#
# == details
# There is a shortcut function ``+.HeatmapList``.
#
# == value
# A `HeatmapList` object.
#
# == author
# Zuguang Gu <z.gu@dkfz.de>
#
setMethod(f = "add_heatmap",
    signature = "HeatmapList",
    definition = function(object, ht) {
    
    # check settings of this new heatmap
    if(inherits(ht, "Heatmap")) {
        ht_name = ht@name
        ht = list(ht)
        names(ht) = ht_name
    }

    # if ht is a HeatmapList, all settings are already checked
    object@ht_list = c(object@ht_list, ht)
    return(object)
})

# == title
# make layout
#
# == param
# -object a `HeatmapList` object
# -row_title title on the row
# -row_title_side side of the row title
# -row_title_gp graphic parameters for drawing text
# -column_title title on the column
# -column_title_side side of the column title
# -column_title_gp graphic parameters for drawing text
# -heatmap_legend_side side of the heatmap legend
# -show_heatmap_legend whether show heatmap legend
# -annotation_legend_side side of annotation legend
# -show_annotation_legend whether show annotation legend
# -hgap gap between heatmaps
# -vgap gap between heatmaps
# -auto_adjust auto adjust if the number of heatmap is larger than one.
#
# == detail
# it makes layout
#
# == value
# a `HeatmapList` object
#
setMethod(f = "make_layout",
    signature = "HeatmapList",
    definition = function(object, row_title = character(0), 
    row_title_side = c("left", "right"), row_title_gp = gpar(fontsize = 14),
    column_title = character(0), column_title_side = c("top", "bottom"), 
    column_title_gp = gpar(fontsize = 14), 
    heatmap_legend_side = c("right", "left", "bottom", "top"), 
    show_heatmap_legend = TRUE,
    annotation_legend_side = c("right", "left", "bottom", "top"), 
    show_annotation_legend = TRUE,
    hgap = unit(5, "mm"), vgap = unit(3, "mm"), auto_adjust = TRUE) {

    if(auto_adjust) {
    	n = length(object@ht_list)
    	if(n > 1) {
    		for(i in seq_len(n-1)+1) {
    			# row cluster should be same as the first one
    			row_order = object@ht_list[[1]]@row_hclust$order
    			object@ht_list[[i]]@matrix = object@ht_list[[i]]@matrix[row_order, , drop = FALSE]
    			object@ht_list[[i]]@row_hclust = NULL
    			object@ht_list[[i]]@layout$layout_row_hclust_left_width = unit(0, "null")
    			object@ht_list[[i]]@layout$layout_row_hclust_right_width = unit(0, "null")
    		}
    	}
    }

    object@layout$layout_annotation_legend_left_width = NULL
    object@layout$layout_heatmap_legend_left_width = NULL
    object@layout$layout_row_title_left_width = NULL
    object@layout$layout_row_title_right_width = NULL
    object@layout$layout_heatmap_legend_right_width = NULL
    object@layout$layout_annotation_legend_right_width = NULL

    object@layout$layout_annotation_legend_top_height = NULL
    object@layout$layout_heatmap_legend_top_height = NULL
    object@layout$layout_column_title_top_height = NULL
    object@layout$layout_column_title_bottom_height = NULL
    object@layout$layout_heatmap_legend_bottom_height = NULL
    object@layout$layout_annotation_legend_bottom_height = NULL

    object@layout$layout_index = rbind(c(4, 4))
    object@layout$graphic_fun_list = list(function(object) draw_heatmap_list(object, hgap))

    ############################################
    ## title on top or bottom
    column_title_side = match.arg(column_title_side)[1]
    if(length(column_title) == 0) {
        column_title = character(0)
    } else if(is.na(column_title)) {
        column_title = character(0)
    } else if(column_title == "") {
        column_title = character(0)
    }
    if(length(column_title) > 0) {
        column_title = column_title
        if(column_title_side == "top") {
            object@layout$layout_column_title_top_height = grobHeight(textGrob(column_title, gp = column_title_gp))*2
            object@layout$layout_column_title_bottom_height = unit(0, "null")
            object@layout$layout_index = rbind(object@layout$layout_index, c(3, 4))
        } else {
            object@layout$layout_column_title_bottom_height = grobHeight(textGrob(column_title, gp = column_title_gp))*2
            object@layout$layout_column_title_top_height = unit(0, "null")
            object@layout$layout_index = rbind(object@layout$layout_index, c(5, 4))
        }
        object@layout$graphic_fun_list = c(object@layout$graphic_fun_list, function(object) object@draw_title(object, column_title, which = "column", side = column_title_side))
    } else {
        object@layout$layout_column_title_top_height = unit(0, "null")
        object@layout$layout_column_title_bottom_height = unit(0, "null")
    }

    ############################################
    ## title on left or right
    row_title_side = match.arg(row_title_side)[1]
    if(length(row_title) == 0) {
        row_title = character(0)
    } else if(is.na(row_title)) {
        row_title = character(0)
    } else if(row_title == "") {
        row_title = character(0)
    }
    if(length(row_title) > 0) {
        row_title = row_title
        if(row_title_side == "left") {
            object@layout$layout_row_title_left_width = grobHeight(textGrob(row_title, gp = row_title_gp))*2
            object@layout$layout_row_title_right_width = unit(0, "null")
            object@layout$layout_index = rbind(object@layout$layout_index, c(4, 3))
        } else {
            object@layout$layout_row_title_right_width = grobHeight(textGrob(row_title, gp = row_title_gp))*2
            object@layout$layout_row_title_left_width = unit(0, "null")
            object@layout$layout_index = rbind(object@layout$layout_index, c(4, 5))
        }
        object@layout$graphic_fun_list = c(object@layout$graphic_fun_list, function(object) draw_title(object, row_title, which = "row", side = row_title_side))
    } else {
        object@layout$layout_row_title_right_width = unit(0, "null")
        object@layout$layout_row_title_left_width = unit(0, "null")
    }

    #################################################
    ## heatmap legend to top, bottom, left and right
    # default values
    object@layout$layout_heatmap_legend_top_height = unit(0, "null")
    object@layout$layout_heatmap_legend_bottom_height = unit(0, "null")
    object@layout$layout_heatmap_legend_left_width = unit(0, "null")
    object@layout$layout_heatmap_legend_right_width = unit(0, "null")
    if(show_heatmap_legend) {
        heatmap_legend_side = match.arg(heatmap_legend_side)[1]
        if(heatmap_legend_side == "top") {
            object@layout$layout_heatmap_legend_top_height = heatmap_legend_size(object, side = "top")[2]
            object@layout$layout_index = rbind(object@layout$layout_index, c(2, 4))
        } else if(heatmap_legend_side == "bottom") {
            object@layout$layout_heatmap_legend_bottom_height = heatmap_legend_size(object, side = "bottom")[2]
            object@layout$layout_index = rbind(object@layout$layout_index, c(6, 4))
        } else if(heatmap_legend_side == "left") {
            object@layout$layout_heatmap_legend_left_width = heatmap_legend_size(object, side = "left")[1]
            object@layout$layout_index = rbind(object@layout$layout_index, c(4, 2))
        } else if(heatmap_legend_side == "right") {
            object@layout$layout_heatmap_legend_right_width = heatmap_legend_size(object, side = "right")[1]
            object@layout$layout_index = rbind(object@layout$layout_index, c(4, 6))
        }
        object@layout$graphic_fun_list = c(object@layout$graphic_fun_list, function(object) draw_heatmap_legend(object, side = heatmap_legend_side))
    }

    #################################################
    ## annotation legend to top, bottom, left and right
    # default values
    object@layout$layout_annotation_legend_top_height = unit(0, "null")
    object@layout$layout_annotation_legend_bottom_height = unit(0, "null")
    object@layout$layout_annotation_legend_left_width = unit(0, "null")
    object@layout$layout_annotation_legend_right_width = unit(0, "null")
    if(show_annotation_legend) {
        annotation_legend_side = match.arg(annotation_legend_side)[1]
        if(annotation_legend_side == "top") {
            object@layout$layout_annotation_legend_top_height = annotation_legend_size(object, side = "top")[2]
            object@layout$layout_index = rbind(object@layout$layout_index, c(1, 4))
        } else if(annotation_legend_side == "bottom") {
            object@object@layout$layout_annotation_legend_bottom_height = annotation_legend_size(object, side = "bottom")[2]
            object@layout$layout_index = rbind(object@layout$layout_index, c(7, 4))
        } else if(heatmap_legend_side == "left") {
            object@layout$layout_annotation_legend_left_width = annotation_legend_size(object, side = "left")[1]
            object@layout$layout_index = rbind(object@layout$layout_index, c(4, 1))
        } else if(annotation_legend_side == "right") {
            object@layout$layout_annotation_legend_right_width = annotation_legend_size(object, side = "right")[1]
            object@layout$layout_index = rbind(object@layout$layout_index, c(4, 7))
        }
        object@layout$graphic_fun_list = c(object@layout$graphic_fun_list, function(object) draw_annotation_legend(object, side = annotation_legend_side))
    }

    return(object)
})

# == title
# Draw a list of heatmaps
#
# == param
# -object a `HeatmapList` object
# -... pass to `make_layout,HeatmapList-method`
# -newpage whether to create a new page
#
# == value
# This function returns no value.
#
# == author
# Zuguang Gu <z.gu@dkfz.de>
#
setMethod(f = "draw",
    signature = "HeatmapList",
    definition = function(object, ..., newpage = TRUE) {

    object = make_layout(object, ...)

    if(newpage) {
        grid.newpage()
    }

    layout = grid.layout(nrow = 7, ncol = 7, widths = component_width(object, 1:7), heights = component_height(object, 1:7))
    pushViewport(viewport(layout = layout, name = "global"))
    ht_layout_index = object@layout$layout_index
    ht_graphic_fun_list = object@layout$graphic_fun_list
    
    for(j in seq_len(nrow(ht_layout_index))) {
        pushViewport(viewport(layout.pos.row = ht_layout_index[j, 1], layout.pos.col = ht_layout_index[j, 2]))
        ht_graphic_fun_list[[j]](object)
        upViewport()
    }

    upViewport()
})

# == title
# width of each components
#
# == param
# -object a `HeatmapList` object
# -k components
#
setMethod(f = "component_width",
    signature = "HeatmapList",
    definition = function(object, k = 1:7) {

    .single_unit = function(k) {
        if(k == 1) {
            object@layout$layout_annotation_legend_left_width
        } else if(k == 2) {
            object@layout$layout_heatmap_legend_left_width
        } else if(k == 3) {
            object@layout$layout_row_title_left_width
        } else if(k == 4) {
            unit(1, "null")
        } else if(k == 5) {
            object@layout$layout_row_title_right_width
        } else if(k == 6) {
            object@layout$layout_heatmap_legend_right_width
        } else if(k == 7) {
            object@layout$layout_annotation_legend_right_width
        } else {
            stop("wrong 'k'")
        }
    }

    do.call("unit.c", lapply(k, function(i) .single_unit(i)))
})

# == title
# height of components
#
# == param
# -object a `HeatmapList` object
# -k components
#
setMethod(f = "component_height",
    signature = "HeatmapList",
    definition = function(object, k = 1:7) {

    .single_unit = function(k) {
        if(k == 1) {
            object@layout$layout_annotation_legend_top_height
        } else if(k == 2) {
            object@layout$layout_heatmap_legend_top_height
        } else if(k == 3) {
            object@layout$layout_column_title_top_height
        } else if(k == 4) {
            unit(1, "null")
        } else if(k == 5) {
            object@layout$layout_column_title_bottom_height
        } else if(k == 6) {
            object@layout$layout_heatmap_legend_bottom_height
        } else if(k == 7) {
            object@layout$layout_annotation_legend_bottom_height
        } else {
            stop("wrong 'k'")
        }
    }

    do.call("unit.c", lapply(k, function(i) .single_unit(i)))
})


# == title
# plot list of heatmaps
#
# == param
# -object a `HeatmapList` object
# -hgap gap
#
setMethod(f = "draw_heatmap_list",
    signature = "HeatmapList",
    definition = function(object, hgap = unit(2, "mm")) {

    n = length(object@ht_list)
    if(n > 1) {
	    if(length(hgap) == 1) hgap = rep(hgap, n-1)
	    hgap = rep(hgap, ceiling((n-1)/length(hgap)))[seq_len(n-1)]
	} else {
		hgap = unit(0, "mm")
	}

    # since each heatmap actually has nine rows, calculate the maximum height of corresponding rows in all heatmap 
    max_component_height = unit.c(
        max(do.call("unit.c", lapply(object@ht_list, function(ht) component_height(ht, k = 1)))),
        max(do.call("unit.c", lapply(object@ht_list, function(ht) component_height(ht, k = 2)))),
        max(do.call("unit.c", lapply(object@ht_list, function(ht) component_height(ht, k = 3)))),
        max(do.call("unit.c", lapply(object@ht_list, function(ht) component_height(ht, k = 4)))),
        unit(1, "null"),
        max(do.call("unit.c", lapply(object@ht_list, function(ht) component_height(ht, k = 6)))),
        max(do.call("unit.c", lapply(object@ht_list, function(ht) component_height(ht, k = 7)))),
        max(do.call("unit.c", lapply(object@ht_list, function(ht) component_height(ht, k = 8)))),
        max(do.call("unit.c", lapply(object@ht_list, function(ht) component_height(ht, k = 9))))
    )

    # set back to each heatmap
    for(i in seq_len(n)) {
        set_component_height(object@ht_list[[i]], k = 1, max_component_height[1])
        set_component_height(object@ht_list[[i]], k = 2, max_component_height[2])
        set_component_height(object@ht_list[[i]], k = 3, max_component_height[3])
        set_component_height(object@ht_list[[i]], k = 4, max_component_height[4])
        set_component_height(object@ht_list[[i]], k = 6, max_component_height[6])
        set_component_height(object@ht_list[[i]], k = 7, max_component_height[7])
        set_component_height(object@ht_list[[i]], k = 8, max_component_height[8])
        set_component_height(object@ht_list[[i]], k = 9, max_component_height[9])
    }

    width_without_heatmap_body = do.call("unit.c", lapply(object@ht_list, function(ht) component_width(ht, c(1:3, 5:7))))
    heatmap_ncol = sapply(object@ht_list, function(ht) ncol(ht@matrix))

    # width for body for each heatmap
    heatmap_body_width = (unit(1, "npc") - sum(width_without_heatmap_body) - sum(hgap)) * (1/sum(heatmap_ncol)) * heatmap_ncol

    # width of heatmap including body, and other components
    heatmap_width = sum(width_without_heatmap_body[1:3]) + heatmap_body_width[1] + sum(width_without_heatmap_body[5:7-1])

    for(i in seq_len(n - 1) + 1) {
        heatmap_width = unit.c(heatmap_width, sum(width_without_heatmap_body[6*(i-1) + 1:3]) + heatmap_body_width[i] + sum(width_without_heatmap_body[6*(i-1) + 5:7-1]))
    }

    pushViewport(viewport(name = "main_heatmap_list"))
    
    x = unit(0, "npc")
    for(i in seq_len(n)) {
        pushViewport(viewport(x = x, y = unit(0, "npc"), width = heatmap_width[i], just = c("left", "bottom"), name = paste0("heatmap_", object@ht_list[[i]]@name)))
        ht = object@ht_list[[i]]
        draw(ht, internal = TRUE)
        upViewport()

        if(i < n) {
        	x = x + sum(heatmap_width[seq_len(i)]) + sum(hgap[seq_len(i)])
        }
    }

    upViewport()

})

# == title
# draw title
#
# == param
# -object a `HeatmapList` object
# -title title
# -which which
# -side side
# -gp graphic parameters for drawing text
#
setMethod(f = "draw_title",
    signature = "HeatmapList",
    definition = function(object, title, which = c("row", "column"),
    side = ifelse(which == "row", "right", "bottom"), gp = NULL) {

    which = match.arg(which)[1]

    side = side[1]
    if(which == "row" && side %in% c("bottom", "top")) {
        stop("`side` can only be set to 'left' or 'right' if `which` is 'row'.")
    }

    if(which == "column" && side %in% c("left", "right")) {
        stop("`side` can only be set to 'top' or 'bottom' if `which` is 'column'.")
    }

    if(is.null(gp)) {
        gp = switch(which,
            "row" = object@gp_list$row_title_gp,
            "column" = object@gp_list$column_title_gp)
    }

    if(which == "row") {
        rot = switch(side,
            "left" = 90,
            "right" = 270)

        pushViewport(viewport(name = "global_row_title", clip = FALSE))
        grid.text(title, rot = rot, gp = gp)
        upViewport()
    } else {
        pushViewport(viewport(name = "global_column_title", clip = FALSE))
        grid.text(title, gp = gp)
        upViewport()
    }
})

# == title
# draw heatmap legend
#
# == param
# -object a `HeatmapList` object
# -side side
#
setMethod(f = "draw_heatmap_legend",
    signature = "HeatmapList",
    definition = function(object, side = c("right", "left", "top", "bottom")) {

    side = match.arg(side)[1]

    ColorMappingList = lapply(object@ht_list, function(ht) ht@matrix_color_mapping)
    draw_legend(ColorMappingList, side = side)
})

# == title
# draw annotation legend
#
# == param
# -object a `HeatmapList` object
# -side side
#
setMethod(f = "draw_annotation_legend",
    signature = "HeatmapList",
    definition = function(object, side = c("right", "left", "top", "bottom")) {

    side = match.arg(side)[1]

    ColorMappingList = do.call("c", lapply(object@ht_list, function(ht) ht@column_anno_color_mapping))
    nm = names(ColorMappingList)
    ColorMappingList = ColorMappingList[nm]
    draw_legend(ColorMappingList, side = side)
})

# == title
# get heatmap legend size
#
# == param
# -object a `HeatmapList` object
# -side side
#
setMethod(f = "heatmap_legend_size",
    signature = "HeatmapList",
    definition = function(object, side = c("right", "left", "top", "bottom")) {

    side = match.arg(side)[1]

    ColorMappingList = lapply(object@ht_list, function(ht) ht@matrix_color_mapping)
    draw_legend(ColorMappingList, side = side, plot = FALSE)
})

# == title
# get anntation legend size
#
# == param
# -object a `HeatmapList` object
# -side side
# -vp_width vp_width
# -vp_height vp_height
#
setMethod(f = "annotation_legend_size",
    signature = "HeatmapList",
    definition = function(object, side = c("right", "left", "top", "bottom"), 
    vp_width = unit(1, "npc"), vp_height = unit(1, "npc")) {

    side = match.arg(side)[1]

    ColorMappingList = do.call("c", lapply(object@ht_list, function(ht) ht@column_anno_color_mapping))
    nm = names(ColorMappingList)
    ColorMappingList = ColorMappingList[nm]
    draw_legend(ColorMappingList, side = side, plot = FALSE, vp_width = vp_width, vp_height = vp_height)
})

draw_legend = function(ColorMappingList, side = c("right", "left", "top", "bottom"), plot = TRUE,
    vp_width = unit(1, "npc"), vp_height = unit(1, "npc"), gap = unit(2, "mm"), 
    padding = unit(4, "mm")) {

    side = match.arg(side)[1]

    n = length(ColorMappingList)

    if(side %in% c("left", "right")) {
    	if(side == "left") {
        	current_x = unit(0, "npc")
        } else {
        	current_x = unit(0, "npc") + padding
        }
        current_width = unit(0, "null")
        current_y = vp_height
        for(i in seq_len(n)) {
            cm = ColorMappingList[[i]]
            size = color_mapping_legend(cm, plot = FALSE)
            # if this legend is too long that it exceed the bottom of the plotting region
            # it also works for the first legend if it is too long
            #if(compare_unit(current_y - size[2], unit(0, "npc")) < 0) {
            if(0){
                # go to next column
                current_y = unit(1, "npc")
                current_x = current_width
                current_width = current_x + size[1]

                if(plot) color_mapping_legend(cm, x = current_x, y = current_y, just = c("left", "top"), plot = TRUE)
                current_y = current_y - size[2] # move to the bottom
            } else {
                # if this legend is wider
                if(compare_unit(current_width, current_x + size[1]) < 0) {
                    current_width = current_x + size[1]
                }

                if(plot) color_mapping_legend(cm, x = current_x, y = current_y, just = c("left", "top"), plot = TRUE)
                current_y = current_y - size[2] - gap # move to the bottom
            }
        }

        if(side == "left") {
        	current_width = current_width + padding
        }

        return(unit.c(current_width, vp_height))

    } else if(side %in% c("top", "bottom")) {
        current_x = unit(0, "npc")
        if(side == "top") {
        	current_height = vp_height
        } else {
        	current_height = vp_height - padding
        }
        current_y = vp_height
        for(i in seq_len(n)) {
            cm = ColorMappingList[[i]]
            size = color_mapping_legend(cm, plot = FALSE)
            
            # if adding the legend exceeding ...
            #if(compare_unit(current_x + size[1], vp_width) > 0) {
            if(0) {
                # go to next column
                current_y = unit(1, "npc") - current_height
                current_x = unit(0, "npc")
                current_height = current_y - size[2]

                if(plot) color_mapping_legend(cm, x = current_x, y = current_y, just = c("left", "top"), plot = TRUE)
                current_x = current_x + size[1]
            } else {
                # if height of this legend is larger
                if(compare_unit(current_height, current_y - size[2]) > 0) {
                    current_height = current_y - size[2]
                }

                if(plot) color_mapping_legend(cm, x = current_x, y = current_y, just = c("left", "top"), plot = TRUE)
                current_x = current_x + size[1] + gap
            }
        }
        if(side == "top") {
        	current_height = current_height - padding
        }

        return(unit.c(vp_width, unit(1, "npc") - current_height))
        
    }
}

setMethod(f = "show",
    signature = "HeatmapList",
    definition = function(object) {

    cat("A HeatmapList object containing", length(object@ht_list), "heatmaps:\n\n")
    for(i in seq_along(object@ht_list)) {
        cat("[", i, "] ", sep = "")
        show(object@ht_list[[i]])
        cat("\n")
    }
})

# == title
# Add heatmaps to the list
#
# == param
# -ht1 a `HeatmapList` object.
# -ht2 a `Heatmap` object or a `HeatmapList` object.
#
# == value
# A `HeatmapList` object
#
# == author
# Zuguang Gu <z.gu@dkfz.de>
#
"+.HeatmapList" = function(ht1, ht2) {
    if(inherits(ht2, "Heatmap") || inherits(ht2, "HeatmapList")) {
        add_heatmap(ht1, ht2)
    } else {
        stop("`ht2` should be a `Heatmap` or `HeatmapList` object.")

    }
}


compare_unit = function(u1, u2) {
    u1 = convertUnit(u1, "cm", valueOnly = TRUE)
    u2 = convertUnit(u2, "cm", valueOnly = TRUE)
    ifelse(u1 > u2, 1, ifelse(u1 < u2, -1, 0))
}
