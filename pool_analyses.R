library(pacman)
p_load(RColorBrewer, ggplot2, ggrepel, dplyr, openxlsx, here, ggpubr)

pall <- colorRampPalette(brewer.pal(8, "Set2"))(10)

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
brasileirao$matchday <- rep_round <- factor(rep(1:38, each=10))

result_table <- openxlsx::read.xlsx('brasileirao_last5years.xlsx', sheet = 'table')
result_table$year <- factor(result_table$year)
brasileirao <- brasileirao%>%left_join(result_table, by=c("home_team"="team", "year"))
brasileirao <- brasileirao%>%left_join(result_table, by=c("away_team"="team", "year"), suffix=c("_home", "_away"))

table_acc <- result_table%>%
  filter(position<=5)%>%
  group_by(team)%>%tally()%>%
  rename("top_pos_5y"=n)

table2020 <- result_table%>%
  filter(year=="2020")%>%
  left_join(table_acc, by="team")
#write.csv(table2020, "table_2020.csv", fileEncoding="latin1", row.names=FALSE)

##### QUESTION 1 - Which was the distribution of the Home, Away Widns and Draws in the past 5 years? #####

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

##### QUESTION 2 - Which were the distribution of the scores in the past 5 years? #####

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

##### QUESTION 3 - Which % of the home, away wins and draws for the score by year? #####
# We do expect some tendencies of scores 0-X, 1-X, X-1, and 2-X, but how often they happend?

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


##### QUESTION 4 - There's a tendency for the teams with better scores to relax in the end of the championship? #####

# All teams
gen_home_md_win <- brasileirao%>%
  filter(type_win=='Home Win')%>%
  ggplot(aes(x=matchday, fill=year)) +
  geom_bar(position = position_dodge2(reverse=TRUE)) +
  scale_fill_brewer(palette = 'Set2') +
  geom_text(stat='count', aes(label = after_stat(count)), position = position_dodge2(width = .9, reverse=TRUE), vjust = -0.25, size = 5) +
  labs(title="Home Win by Year and Matchday", x="Year", y="Counts", fill="Matchday")+
  theme_bw()

gen_home_md_win_perc <- brasileirao%>%
  filter(type_win=='Home Win')%>%
  ggplot(aes(x=matchday, fill=year)) +
  geom_bar(stat='count', position = "fill") +
  scale_fill_brewer(palette = 'Set2') +
  geom_text(aes(label = paste0(round((..count../tapply(..count.., ..x.. ,sum)[..x..])*100, 2),'%')),
            position = position_fill(vjust = 0.5), stat = "count", size = 4) +
  scale_y_continuous(labels = scales::percent) + 
  labs(title="% Home Win by Year and Matchday", x="Year", y="Counts", fill="Matchday")+
  theme_bw()

composite_home_md_win <- ggarrange(gen_home_md_win, gen_home_md_win_perc, nrow=1)
composite_home_md_win

# Top 5
gen_top5_match <- brasileirao%>%
  filter(position_home<=5 | position_away<=5)%>%
  ggplot(aes(x=matchday, fill=year)) +
  geom_bar(position = position_dodge2(reverse=TRUE)) +
  scale_fill_brewer(palette = 'Set2') +
  geom_text(stat='count', aes(label = after_stat(count)), position = position_dodge2(width = .9, reverse=TRUE), vjust = -0.25, size = 5) +
  labs(title="Home Win by Year and Matchday", x="Year", y="Counts", fill="Matchday")+
  theme_bw()

gen_top5_match_perc <- brasileirao%>%
  filter(position_home<=5 | position_away<=5)%>%
  ggplot(aes(x=matchday, fill=year)) +
  geom_bar(stat='count', position = "fill") +
  scale_fill_brewer(palette = 'Set2') +
  geom_text(aes(label = paste0(round((..count../tapply(..count.., ..x.. ,sum)[..x..])*100, 2),'%')),
            position = position_fill(vjust = 0.5), stat = "count", size = 4) +
  scale_y_continuous(labels = scales::percent) + 
  labs(title="% Home Win by Year and Matchday", x="Year", y="Counts", fill="Matchday")+
  theme_bw()

composite_top5_match <- ggarrange(gen_top5_match, gen_top5_match_perc, nrow=1)
composite_top5_match

##### OTHER #####
pall <- colorRampPalette(brewer.pal(8, "Set2"))(12)

gen_team <- result_table%>%
  filter(position<=5)%>%
  ggplot(aes(x=team, fill=team)) +
  geom_bar(position = position_dodge2(reverse=TRUE)) +
  scale_fill_manual(values = pall) +
  geom_text(stat='count', aes(label = after_stat(count)), position = position_dodge2(width = .9, reverse=TRUE), vjust = -0.25, size = 5) +
  labs(title="Type of Win by Year", x="Year", y="Counts", fill="Type of Win")+
  theme_bw()
gen_team

gen_team <- brasileirao%>%
  filter(status_home=="top 4", type_win=="Home Win")%>%
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

tb_top5 <-brasileirao%>%
  filter(year=="2020", position_home<=5)%>%
  group_by(type_win)%>%
  tally()

tb_other <-brasileirao%>%
  filter(year=="2020", position_home>5)%>%
  group_by(type_win)%>%
  tally()

top5_score <- brasileirao%>%
  filter(year=="2020", position_home<=5)%>%
  ggplot(aes(x=type_win, fill=type_win)) +
  geom_bar(position = position_dodge2(reverse=TRUE)) +
  scale_fill_manual(values = pall) +
  geom_text(stat='count', aes(label = after_stat(count)), position = position_dodge2(width = .9, reverse=TRUE), vjust = -0.25, size = 5) +
  labs(title="Top 5 Scores by Matchday", x="Score", y="Counts", fill="Matchday")+
  theme_bw()

las15_score <- brasileirao%>%
  filter(year=="2020", position_home>5)%>%
  ggplot(aes(x=type_win, fill=type_win)) +
  geom_bar(position = position_dodge2(reverse=TRUE)) +
  scale_fill_manual(values = pall) +
  geom_text(stat='count', aes(label = after_stat(count)), position = position_dodge2(width = .9, reverse=TRUE), vjust = -0.25, size = 5) +
  labs(title="Top 5 Scores by Matchday", x="Score", y="Counts", fill="Matchday")+
  theme_bw()


las7_score <- brasileirao%>%
  filter(year=="2020", position_home>13)%>%
  ggplot(aes(x=type_win, fill=type_win)) +
  geom_bar(position = position_dodge2(reverse=TRUE)) +
  scale_fill_manual(values = pall) +
  geom_text(stat='count', aes(label = after_stat(count)), position = position_dodge2(width = .9, reverse=TRUE), vjust = -0.25, size = 5) +
  labs(title="Top 5 Scores by Matchday", x="Score", y="Counts", fill="Matchday")+
  theme_bw()

composite_top_last <- ggarrange(top5_score, las15_score, las7_score, nrow=1)
composite_top_last

top5_low11_score <- brasileirao%>%
  filter(year=="2020", (position_home<=5 & position_away>=11))%>%
  ggplot(aes(x=type_win, fill=type_win)) +
  geom_bar(position = position_dodge2(reverse=TRUE)) +
  scale_fill_manual(values = pall) +
  geom_text(stat='count', aes(label = after_stat(count)), position = position_dodge2(width = .9, reverse=TRUE), vjust = -0.25, size = 5) +
  labs(title="5 Top x Lox Scores by Away Team", x="Score", y="Counts", fill="Matchday")+
  theme_bw()

low5_top11_score <- brasileirao%>%
  filter(year=="2020", (position_home>=16 & position_away<=10))%>%
  ggplot(aes(x=type_win, fill=type_win)) +
  geom_bar(position = position_dodge2(reverse=TRUE)) +
  scale_fill_manual(values = pall) +
  geom_text(stat='count', aes(label = after_stat(count)), position = position_dodge2(width = .9, reverse=TRUE), vjust = -0.25, size = 5) +
  labs(title="5 Top x Lox Scores by Away Team", x="Score", y="Counts", fill="Matchday")+
  theme_bw()

composite_top5 <- ggarrange(top5_low11_score, low5_top11_score, nrow=1)
composite_top5

tb_fla_score <- result_table%>%
  filter(team=="FLAMENGO")

tb_pal_score <- result_table%>%
  filter(team=="PALMEIRAS")
