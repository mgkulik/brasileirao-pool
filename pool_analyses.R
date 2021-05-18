library(pacman)
p_load(RColorBrewer, ggplot2, ggrepel, dplyr, openxlsx, here, ggpubr)

#brasileirao2021 <- openxlsx::read.xlsx('brasileirao_2021.xlsx', sheet = 'Sheet1')
brasileirao <- openxlsx::read.xlsx('brasileirao_last5years.xlsx', sheet = 'matches')
geo <- openxlsx::read.xlsx('brasileirao_last5years.xlsx', sheet = 'region')
brasileirao <- brasileirao%>%left_join(geo, by=c("home_team"="team"))

brasileirao$year <- factor(brasileirao$year)
brasileirao$type_win <- factor(ifelse(brasileirao$home_score>brasileirao$away_score, 'Home Win', 
                               ifelse(brasileirao$home_score<brasileirao$away_score, 'Away Win', 'Draw')))
brasileirao$score <- factor(paste0(as.character(brasileirao$home_score), 'X' , as.character(brasileirao$away_score)))
brasileirao$home_score_cat <- factor(ifelse(brasileirao$type_win == 'Home Win', 
                                            ifelse(brasileirao$home_score==1, '1',
                                                   ifelse(brasileirao$home_score==2, '2', 
                                                          ifelse(brasileirao$home_score==3, '3', '4-6'))), NA))
brasileirao$away_score_cat <- factor(ifelse(brasileirao$type_win == 'Away Win',
                                            ifelse(brasileirao$away_score==1, '1', 
                                                   ifelse(brasileirao$away_score==2, '2', 
                                                          ifelse(brasileirao$away_score==3, '3', '4-6'))), NA))
brasileirao$draw_score_cat <- factor(ifelse(brasileirao$type_win == 'Draw',
                                            ifelse(brasileirao$away_score==0, '0', 
                                                   ifelse(brasileirao$away_score==1, '1', 
                                                          ifelse(brasileirao$away_score==2, '2',
                                                                 ifelse(brasileirao$away_score==3, '3', '4-6')))), NA))
brasileirao$matchday <- rep_round <- factor(rep(1:10, nrow(brasileirao)/10))

result_table <- openxlsx::read.xlsx('brasileirao_last5years.xlsx', sheet = 'table')
result_table$year <- factor(result_table$year)
brasileirao <- brasileirao%>%left_join(result_table, by=c("home_team"="team", "year"))

gen_year_win <- ggplot(brasileirao, aes(x=year, fill=type_win)) +
  geom_bar(position = position_dodge2(reverse=TRUE)) +
  scale_fill_brewer(palette = "Set2") +
  geom_text(stat='count', aes(label = after_stat(count)), position = position_dodge2(width = .9, reverse=TRUE), vjust = -0.25, size = 5) +
  labs(title="Type of Win by Year", x="Year", y="Counts", fill="Type of Win")+
  theme_bw()
#gen_year_win

gen_year_win_perc <- ggplot(brasileirao, aes(x=year, fill=type_win)) +
  geom_bar(stat='count', position = "fill") +
  scale_fill_brewer(palette = "Set2") +
  geom_text(aes(label = paste0(round((..count../tapply(..count.., ..x.. ,sum)[..x..])*100, 2),'%')),
                  position = position_fill(vjust = 0.5), stat = "count", size = 4) +
  scale_y_continuous(labels = scales::percent) + 
  labs(title="Type of Win by Year", x="Year", y="Counts", fill="Type of Win")+
  theme_bw()
#gen_year_win_perc

composite_type_win <- ggarrange(gen_year_win, gen_year_win_perc, widths=c(2,1))
composite_type_win

gen_year_score <- ggplot(brasileirao, aes(x=score, fill=year)) +
  geom_bar(position = position_dodge2(reverse=TRUE)) +
  scale_fill_brewer(palette = "Set2") +
  geom_text(stat='count', aes(label = after_stat(count)), position = position_dodge2(width = .9, reverse=TRUE), vjust = -0.25, size = 5) +
  labs(title="Score by Year", x="Score", y="Counts", fill="Year")+
  theme_bw()
gen_year_score

gen_year_score_perc <- ggplot(brasileirao, aes(x=score, fill=year)) +
  geom_bar(stat='count', position = "fill") +
  scale_fill_brewer(palette = "Set2") +
  geom_text(aes(label = paste0(round((..count../tapply(..count.., ..x.. ,sum)[..x..])*100, 2),'%')),
            position = position_fill(vjust = 0.5), stat = "count", size = 4) +
  scale_y_continuous(labels = scales::percent) + 
  labs(title="% Score by Year", x="Score", y="Counts", fill="Year")+
  theme_bw()
gen_year_score_perc

gen_home_cat_perc <- brasileirao%>%
  filter(type_win=='Home Win')%>%
  ggplot(aes(x=year, fill=home_score_cat)) +
  geom_bar(stat='count', position = "fill") +
  scale_fill_brewer(palette = "Set2") +
  geom_text(aes(label = paste0(round((..count../tapply(..count.., ..x.. ,sum)[..x..])*100, 2),'%')),
            position = position_fill(vjust = 0.5), stat = "count", size = 4) +
  scale_y_continuous(labels = scales::percent) + 
  labs(title="% Score Category for HOME Victories by Year", x="Year", y="Counts", fill="Score Groups")+
  theme(legend.position = "none")+
  theme_bw()

gen_away_cat_perc <- brasileirao%>%
  filter(type_win=='Away Win')%>%
  ggplot(aes(x=year, fill=away_score_cat)) +
  geom_bar(stat='count', position = "fill") +
  scale_fill_brewer(palette = "Set2") +
  geom_text(aes(label = paste0(round((..count../tapply(..count.., ..x.. ,sum)[..x..])*100, 2),'%')),
            position = position_fill(vjust = 0.5), stat = "count", size = 4) +
  scale_y_continuous(labels = scales::percent) + 
  labs(title="% Score Category for AWAY Victories by Year", x="Year", y="Counts", fill="Score Groups")+
  theme_bw()

gen_draw_cat_perc <- brasileirao%>%
  filter(type_win=='Draw')%>%
  ggplot(aes(x=year, fill=draw_score_cat)) +
  geom_bar(stat='count', position = "fill") +
  scale_fill_brewer(palette = "Set2") +
  geom_text(aes(label = paste0(round((..count../tapply(..count.., ..x.. ,sum)[..x..])*100, 2),'%')),
            position = position_fill(vjust = 0.5), stat = "count", size = 4) +
  scale_y_continuous(labels = scales::percent) + 
  labs(title="% Score Category for DRAW by Year", x="Year", y="Counts", fill="Score Groups")+
  theme_bw()

composite_score_groups <- ggarrange(gen_home_cat_perc, gen_away_cat_perc, gen_draw_cat_perc, nrow=1)
ggplot2::ggsave("composite_score_groups.png", composite_score_groups, units = "in", width = 20, height = 8, dpi = 300)

gen_home_cat <- brasileirao%>%
  filter(type_win=='Home Win')%>%
  ggplot(aes(x=year, fill=home_score_cat)) +
  geom_bar(position = position_dodge2(reverse=TRUE)) +
  scale_fill_brewer(palette = "Set2") +
  geom_text(stat='count', aes(label = after_stat(count)), position = position_dodge2(width = .9, reverse=TRUE), vjust = -0.25, size = 5) +
  labs(title="Score Category for HOME Victories by Year", x="Year", y="Counts", fill="Score Groups")+
  theme(legend.position = "none")+
  theme_bw()

gen_away_cat <- brasileirao%>%
  filter(type_win=='Away Win')%>%
  ggplot(aes(x=year, fill=away_score_cat)) +
  geom_bar(position = position_dodge2(reverse=TRUE)) +
  scale_fill_brewer(palette = "Set2") +
  geom_text(stat='count', aes(label = after_stat(count)), position = position_dodge2(width = .9, reverse=TRUE), vjust = -0.25, size = 5) +
  labs(title="Score Category for AWAY Victories by Year", x="Year", y="Counts", fill="Score Groups")+
  theme_bw()

gen_draw_cat <- brasileirao%>%
  filter(type_win=='Draw')%>%
  ggplot(aes(x=year, fill=draw_score_cat)) +
  geom_bar(position = position_dodge2(reverse=TRUE)) +
  scale_fill_brewer(palette = "Set2") +
  geom_text(stat='count', aes(label = after_stat(count)), position = position_dodge2(width = .9, reverse=TRUE), vjust = -0.25, size = 5) +
  labs(title="Score Category for DRAW by Year", x="Year", y="Counts", fill="Score Groups")+
  theme_bw()

composite_score_cat <- ggarrange(gen_home_cat, gen_away_cat, gen_draw_cat, nrow=1)
ggplot2::ggsave("composite_score_cat.png", composite_score_cat, units = "in", width = 20, height = 8, dpi = 300)

pall <- colorRampPalette(palette('Set2'))(10)

gen_home_md_win <- brasileirao%>%
  filter(type_win=='Home Win')%>%
  ggplot(aes(x=year, fill=matchday)) +
  geom_bar(position = position_dodge2(reverse=TRUE)) +
  scale_fill_brewer(palette = pall) +
  geom_text(stat='count', aes(label = after_stat(count)), position = position_dodge2(width = .9, reverse=TRUE), vjust = -0.25, size = 5) +
  labs(title="Home Win by Year and Matchday", x="Year", y="Counts", fill="Matchday")+
  theme_bw()

gen_home_md_win_perc <- brasileirao%>%
  filter(type_win=='Home Win')%>%
  ggplot(aes(x=year, fill=matchday)) +
  geom_bar(stat='count', position = "fill") +
  scale_fill_brewer(palette = pall) +
  geom_text(aes(label = paste0(round((..count../tapply(..count.., ..x.. ,sum)[..x..])*100, 2),'%')),
            position = position_fill(vjust = 0.5), stat = "count", size = 4) +
  scale_y_continuous(labels = scales::percent) + 
  labs(title="% Home Win by Year and Matchday", x="Year", y="Counts", fill="Matchday")+
  theme_bw()

composite_home_md_win <- ggarrange(gen_home_md_win, gen_home_md_win_perc, nrow=1)
composite_home_md_win

gen_team <- brasileirao%>%
  filter(status=="top 4", type_win=="Home Win")%>%
  ggplot(aes(x=matchday, fill=home_team)) +
  geom_bar(position = position_dodge2(reverse=TRUE)) +
  scale_fill_brewer(palette = "Set2") +
  geom_text(stat='count', aes(label = after_stat(count)), position = position_dodge2(width = .9, reverse=TRUE), vjust = -0.25, size = 5) +
  labs(title="Type of Win by Year", x="Year", y="Counts", fill="Type of Win")+
  theme_bw()
gen_team


tbl_top_team <- result_table%>%
  filter(status=="top 4")%>%
  group_by(team, year)%>%tally()%>%
  mutate(w=n/length(unique(result_table$year)),
         w2=ifelse(year=='2020', .1, 0))%>%
  group_by(team)
  

gen_team_matches <- result_table%>%
  filter(status=="top 4")%>%
  ggplot(aes(x=team, fill=team)) +
  geom_bar(position = position_dodge2(reverse=TRUE)) +
  scale_fill_brewer(palette = "Set2") +
  geom_text(stat='count', aes(label = after_stat(count)), position = position_dodge2(width = .9, reverse=TRUE), vjust = -0.25, size = 5) +
  labs(title="Type of Win by Year", x="Year", y="Counts", fill="Type of Win")+
  theme_bw()
gen_team_matches

gen_fla_score <- brasileirao%>%
  filter(home_team=="FLAMENGO")%>%
  ggplot(aes(x=score, fill=year)) +
  geom_bar(position = position_dodge2(reverse=TRUE)) +
  scale_fill_brewer(palette = "Set2") +
  facet_grid(~ type_win) +
  geom_text(stat='count', aes(label = after_stat(count)), position = position_dodge2(width = .9, reverse=TRUE), vjust = -0.25, size = 5) +
  labs(title="Flamengo Score", x="Score", y="Counts", fill="Year")+
  theme_bw()
gen_fla_score

tb_fla_score <- result_table%>%
  filter(team=="FLAMENGO")

tb_pal_score <- result_table%>%
  filter(team=="PALMEIRAS")
