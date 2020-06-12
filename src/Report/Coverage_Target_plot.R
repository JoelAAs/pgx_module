library(cowplot)
library(tidyverse)
library(ggplot2)
library(reshape2)

# Set exon/intron lines to bound of plot
out_of_plotting_bounds <- function(frame, start, end) {
  if (nrow(frame)== 0){
    return(frame)
  } else {
    frame[frame$value > end, "value"]  <- end
    frame[frame$value < start, "value"] <- start
    return(frame)
  }
}

get_cov_target_plot <- function(exon_table_file, bait_table_file, target_table_file, gdf_file, gene) {
  ## Input formating
  exon_table        <- read.csv(exon_table_file, sep = ",", as.is=T, check.names = F) %>% filter(Start != "")
  exon_table$Start <- as.numeric(sapply(exon_table$Start, function(x) str_remove_all(x, ",")))
  exon_table$End   <- as.numeric(sapply(exon_table$End, function(x) str_remove_all(x, ",")))
  exon_table$Exon_Intron <- exon_table[, "Exon / Intron"]
  
  bait_table <- read.table(bait_table_file, sep = "\t", as.is=T, check.names = F, 
                           col.names = c("Chr", "Start", "End", "Name")) %>%
    separate(Name, c("Target", "Gene"), "_") %>% 
    filter(Gene == gene)
  row.names(bait_table) <- bait_table$Target
  bait_table <- bait_table[order(bait_table$Start), ]  
  bait_table$Chr <- as.character(bait_table$Chr)
  
  target_table <- read.table(target_table_file, sep = "\t",
                           col.names = c("Chr", "Start", "End", "Rsid", "Gene"))

  
  gdf <- read.csv(gdf_file, sep = "\t") %>% 
    separate(Locus, c("Chr", "Pos"), ":")
  gdf$Pos <- as.numeric(gdf$Pos)
  gdf$Chr <- sapply(gdf$Chr, function(x) gsub("chr", "", x))
  
  ## Plotting
  gene_plot <- list()
  
  current_chr = bait_table$Chr[1]
  gdf <- gdf %>% filter(Chr == current_chr)
  i = 0
  line_pos <- gdf %>%  filter(Average_Depth_sample != 0) %>% {mean(.$Average_Depth_sample)} *0.8
  if (is.nan(line_pos)){
    line_pos <- 0
  }
  max_cov <- max(gdf$Average_Depth_sample, na.rm = T)
  
  ## Plot per bait
  for (bait in bait_table$Target) {
    i = i + 1
    start     <- bait_table[bait, "Start"] - 100
    end       <- bait_table[bait, "End"] + 100
    pos_range <- start:end
    plot_df   <- gdf %>% filter(Pos %in% pos_range)
    plot_exon <- 
      exon_table %>% filter(
        (Start > start | Start > end ) & (End < end | End < end))
    
    plot_exon_melt <- melt(plot_exon[, c("Exon_Intron", "Start", "End")], id.vars = "Exon_Intron")
    plot_exon_melt <- out_of_plotting_bounds(plot_exon_melt, start, end)
    
    target_indel <- target_table %>% filter(Start %in% pos_range, End %in% pos_range) %>%  filter(End != Start) 
    target_snp   <- target_table %>% filter(Start %in% pos_range, End %in% pos_range) %>%  filter(End == Start)
    
    plot_i <- plot_exon_melt[grep("Intron", plot_exon_melt$Exon_Intron), ]
    plot_e <- plot_exon_melt[grep("Intron", plot_exon_melt$Exon_Intron, invert=T), ]
    
    gene_plot[[i]] <- ggplot(plot_df, aes(x=Pos, y=Average_Depth_sample)) +
      geom_line(color="firebrick") +
      xlim(start, end) +
      ylim(0, max_cov*1.1) +
      ggtitle(bait) +
      theme(plot.title = element_text(size = 7, face = "bold")) +
      ylab("Coverage")
    
    if (nrow(plot_i) != 0) {
      gene_plot[[i]] <- gene_plot[[i]] +
        geom_line(data=plot_i,
                  aes(x=value, y=line_pos, group=Exon_Intron),
                  size = 1.5, color="black"
                  )
    }
    
    if (nrow(plot_e) != 0) {
      gene_plot[[i]] <- gene_plot[[i]] +
        geom_line(data=plot_e,
                  aes(x=value, y=line_pos, group=Exon_Intron),
                  size=3, color="blueviolet"
                  )
    }
    
    ## Target Locations
    if (nrow(target_snp) != 0) {
      gene_plot[[i]] <- gene_plot[[i]] +
        geom_point(data=target_snp,
                   aes(x=Start, y=line_pos, group=Rsid),
                   shape=25,
                   size=4,
                   fill="gold3")  
    }
    
    if (nrow(target_indel) != 0){
      target_indel_melt <- melt(target_indel[, c("Rsid", "Start", "End")], id.vars = "Rsid")
      gene_plot[[i]] <- gene_plot[[i]] + 
        geom_point(data=target_indel_melt,
                  aes(x=value, y=line_pos, group=Rsid),
                  size=3,
                  color="gold1")
      
    }
    
    ## Theme
    if (i != 1){
      gene_plot[[i]] <- gene_plot[[i]] +
        theme(axis.title.y=element_blank(),
              axis.text.y=element_blank(),
              axis.text.x=element_text(angle = 90, hjust = 1),
              axis.title.x=element_blank(),
              plot.margin=unit(c(1,0,1.5,0),"points"),
              legend.position='none'
        )
    } else {
      gene_plot[[i]] <- gene_plot[[i]] +
        theme(axis.text.x=element_text(angle = 90, hjust = 1),
              axis.title.x=element_blank(),
              plot.margin=unit(c(1,1,1.5,0),"points"),
              legend.position='none'
        )
    }
    
  }
  
  rel_w = rep(1/length(gene_plot), length(gene_plot))
  rel_w[1] = rel_w[1] * 2 # Since the axis is part of the plot 
  geneplot <- plot_grid(plotlist=gene_plot, nrow = 1, rel_widths = rel_w)
  return(geneplot)
}