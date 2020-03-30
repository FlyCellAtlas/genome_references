gtf <- gread::read_gtf(file = "dmel-all-r6.31.gtf")
gtf_updated <- gread::construct_introns(gtf, update = TRUE)
gtf_updated_df <- as.data.frame(x = gtf_updated)
gtf_updated_df[is.na(x = gtf_updated_df)] <- "."
# Convert intron to exon so that they also will be mapped
gtf_updated_df$feature[gtf_updated_df$feature=="intron"] <- "exon"
# Sort by coordinates
gtf_updated_df <- gtf_updated_df[with(gtf_updated_df, order(seqnames, start)), ]
gtf_updated_df2 <- data.frame(
  "seqname"=gtf_updated_df$seqnames,
  "source"=gtf_updated_df$source,
  "feature"=gtf_updated_df$feature,
  "start"=gtf_updated_df$start,
  "end"=gtf_updated_df$end,
  "score"=gtf_updated_df$score,
  "strand"=gtf_updated_df$strand,
  "frame"=gtf_updated_df$frame,
  "group"=paste0(
    "gene_id \"", gtf_updated_df$gene_id, "\"; "
    , "transcript_id \"", gtf_updated_df$transcript_id, "\"; "
    , "exon_number \"", gtf_updated_df$exon_number, "\"; "
    , "gene_name \"", gtf_updated_df$gene_name, "\";"
  )
)
write.table(x = gtf_updated_df2
            , file = "dmel-all-r6.31.premrna.gtf"
            , quote = FALSE,
            , sep = "\t"
            , row.names = FALSE
            , col.names = FALSE
)