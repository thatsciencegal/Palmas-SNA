#Code for ADN social network analysis for the Palmas meeting
#Developed by A. Christine Swanson

##Load libraries
library(dplyr)
library(ggplot2)
library(tidyr)
library(viridis)
library(network)
library(statnet)
library(sna)
library(numDeriv)

#read in data
init.dat <- read.csv("./Data/ADNPalmasSurveyEdited.csv")
atts <- read.csv("./Data/ADNPalmasAtts.csv")

#Split columns with multiple responses into different rows for each response
init.dat.activities<-init.dat %>% 
  mutate(ADNActivities=strsplit(as.character(ADNActivities),",")) %>% 
  unnest(ADNActivities)

#Change activities to factor
init.dat.activities$ADNActivities<-as.factor(init.dat.activities$ADNActivities)

#Format weird characters
init.dat.activities$ADNActivities[init.dat.activities$ADNActivities=="Coopi Ã¢â‚¬â€œ CooperaÃƒÂ§ÃƒÂ£o Internacional Program"]<-"Coopi"
init.dat.activities$ADNActivities[init.dat.activities$ADNActivities=="PrÃƒÂ³-AmazÃƒÂ´nia Program"]<-"Pro-Amazonia Program"
init.dat.activities$ADNActivities[init.dat.activities$ADNActivities=="Coopi "]<-"Coopi"
init.dat.activities$ADNActivities[init.dat.activities$ADNActivities=="Science without Borders Ã¢â‚¬â€œ Biodiversity and Indigenous Peoples (PVE)"]<-"Science without Borders - Biodiversity and Indigenous Peoples (PVE)"
init.dat.activities$ADNActivities[init.dat.activities$ADNActivities=="Science without Borders "]<-"Science without Borders - Biodiversity and Indigenous Peoples (PVE)"
init.dat.activities$ADNActivities[init.dat.activities$ADNActivities=="Science without Borders"]<-"Science without Borders - Biodiversity and Indigenous Peoples (PVE)"
init.dat.activities$ADNActivities[init.dat.activities$ADNActivities=="Amazon Dams Network Email Listserv Florida"]<-"Amazon Dams Network Email Listserv"
init.dat.activities$ADNActivities[init.dat.activities$ADNActivities=="AND Conferences/Symposia in Brazil"]<-"ADN Conferences/Symposia in Brazil"

#Create a second dataset with only unique names
init.dat.unique<-init.dat.activities[!duplicated(init.dat.activities$First_Name),]

#Filter data to only entries where data on gender exists
init.dat.sex<-filter(init.dat.unique, Gender != "")
#Change gender answer to character
init.dat.sex$Gender<-as.character(init.dat.sex$Gender)
#Format self-describe category
init.dat.sex$Gender[init.dat.sex$Gender=="Prefer to self-describe"]<-"Self-describe"
#Change gender data back to factor
init.dat.sex$Gender<-as.factor(init.dat.sex$Gender)
#Plot gender data
ggplot(init.dat.sex, aes(x=Gender))+
  geom_bar(width=0.25)+
  stat_count(aes(y=..count.., label=..count..), geom="text", vjust=-.5)+
  labs(x="",y="Total")+
  theme_classic()+
  theme(aspect.ratio=2/1)

##Matching all country responses
init.dat.unique$Country[init.dat.unique$Country=="BR"]<-"Brazil"
init.dat.unique$Country[init.dat.unique$Country=="Brasil"]<-"Brazil"
init.dat.unique$Country[init.dat.unique$Country=="Estados Unidos"]<-"United States"
init.dat.unique$Country[init.dat.unique$Country=="U.S.A."]<-"United States"
init.dat.unique$Country[init.dat.unique$Country=="USA"]<-"United States"

#Filter out data where there was no response for country
init.dat.country<-filter(init.dat.unique,Country!="")

#Country plot
ggplot(init.dat.country, aes(x=Country))+
  geom_bar(width=0.25)+
  theme_classic()+
  theme(aspect.ratio=2/1)+
  stat_count(aes(y=..count.., label=..count..), geom="text", vjust=-.5)+
  labs(x="",y="Total")

##Additional plots

#Filter no data for occupation
init.dat.occ<-filter(init.dat, Occupation != "")
#Reorder occupation data into alphabetical order
init.dat.occ$Occupation<-factor(init.dat.occ$Occupation,c("Community leader / representative","Academic faculty",
                                                          "Government employee", "NGO practitioner",
                                                          "Private sector","Undegraduate student",
                                                          "Graduate student","Other"))
#Plot occupational data
ggplot(init.dat.occ, aes(x=Occupation, fill=Occupation))+
  geom_bar()+
  stat_count(aes(y=..count.., label=..count..), geom="text", vjust=-.5)+
  theme_classic()+
  scale_fill_viridis_d(labels=c("Community leader","Academic faculty",
                                "Government employee","NGO practicioner","Private sector",
                                "Undergraduate student","Graduate student","Other"))+
  labs(x="",y="Total")+
  theme(axis.text.x=element_blank(),
        axis.ticks.x =element_blank(), 
        legend.title=element_blank())

#Education data, filter out no response
init.dat.ed<-filter(init.dat.unique,Education !="")
#Re-order education data by degree level
init.dat.ed$Education<-factor(init.dat.ed$Education, c("Some post-secondary education (undergraduate)",
                                                       "Completed post-secondary education (undergraduate)",
                                                       "Master's", "Some Doctoral","Doctoral","Other (please specify)"))
#Plot education data
ggplot(init.dat.ed,aes(x=Education, fill=Education))+
  geom_bar()+
  stat_count(aes(y=..count.., label=..count..), geom="text", vjust=-.5)+
  theme_classic()+
  scale_fill_viridis_d(labels=c("Some undergraduate","Bachelor's","Master's","Some doctoral","Doctoral","Other"))+
  labs(x="",y="Total")+
  theme_classic()+
  theme(axis.text.x=element_blank(),
        axis.ticks.x =element_blank(), 
        legend.title=element_blank())

#Filter out disciplinary category no data
init.dat.small <- filter(init.dat.unique, Disciplinary_Category != "")

#Rename environmental science category
init.dat.small$Disciplinary_Category[init.dat.small$Disciplinary_Category=="Environmental sciences"]<-"Environmental Sciences"

#Plot disciplinary categories
ggplot(init.dat.small,aes(x=Disciplinary_Category, fill=Disciplinary_Category))+
  geom_bar()+
  scale_fill_viridis_d()+
  stat_count(aes(y=..count.., label=..count..), geom="text", vjust=-.5)+
  labs(x="",y="Total")+
  theme_classic()+
  theme(axis.text.x=element_blank(),
        axis.ticks.x =element_blank(), 
        legend.title=element_blank())

#Filter out no data
init.dat.dams<-filter(init.dat,Interest_in_Dams !="")

#Plot
ggplot(init.dat.dams,aes(x=Interest_in_Dams, fill=Interest_in_Dams))+
  geom_bar()+
  scale_fill_viridis_d()+
  labs(x="",y="Total")+
  stat_count(aes(y=..count.., label=..count..), geom="text", vjust=-.5)+
  theme_classic()+
  theme(axis.text.x=element_blank(),
        axis.ticks.x =element_blank(), 
        legend.title=element_blank())

#Filter out no data
init.dat.rivers <- filter(init.dat,River_Basins != "")

#Clean data
init.dat.rivers$River_Basins[init.dat.rivers$River_Basins=="I have not yet worked on dam-related research."]<-NA
init.dat.rivers$River_Basins[init.dat.rivers$River_Basins=="I have not yet worked on dam-related research"]<-NA
init.dat.rivers$River_Basins[init.dat.rivers$River_Basins=="Parana River (Brazil) "]<-"Parana River (Brazil)"
init.dat.rivers$River_Basins[init.dat.rivers$River_Basins=="Tocantis River (Brazil)"]<-"Tocantins River (Brazil)"
init.dat.rivers$River_Basins[init.dat.rivers$River_Basins=="Braco River (Brazil)"]<-"Branco River (Brazil)"

#Data turned into factors
init.dat.rivers$River_Basins <- as.factor(init.dat.rivers$River_Basins)

#Plot data
ggplot(init.dat.rivers,aes(x=River_Basins, fill=River_Basins))+
  geom_bar()+
  scale_fill_viridis_d()+
  labs(x="",y="Total")+
  stat_count(aes(y=..count.., label=..count..), geom="text", vjust=-.5)+
  theme_classic()+
  theme(axis.text.x=element_blank(),
        axis.ticks.x =element_blank(), 
        legend.title=element_blank())


#Filter no data
init.dat.activities <- filter(init.dat.activities, ADNActivities != "")

#Plot data
ggplot(init.dat.activities,aes(x=ADNActivities, fill=ADNActivities))+
  geom_bar()+
  scale_fill_viridis_d()+
  labs(x="",y="Total")+
  stat_count(aes(y=..count.., label=..count..), geom="text", vjust=-.5)+
  theme_classic()+
  theme(axis.text.x=element_blank(),
        axis.ticks.x =element_blank(), 
        legend.title=element_blank())

#Select specific columns
init.dat.prof<-init.dat.unique %>% 
  select(Engage.with.other.researchers.internationally, Information.about.dams,
         Opportunity.to.learn.from.other.perspective,Access.to.funding.opportunities,
         Community.of.practice, Learn.from.US.experience.with.hydropower,
         Professional.Development.Other) 

#Levels vector
lev<-c("Strongly Disagree","Somewhat Disagree", "Neither Agree nor Disagree",
       "Somewhat Agree", "Strongly Agree","")  

#Factor levels for all columns
init.dat.prof[1:7]<-lapply(init.dat.prof[1:7],factor,levels=lev)

#Change from wide to long
init.dat.prof.long <- init.dat.prof %>% 
  gather() %>% 
  filter(value !="")

#Reorder levels
init.dat.prof.long$value<-factor(init.dat.prof.long$value,levels = lev)

#Summarize data by count
init.dat.prof.count <- init.dat.prof.long %>% 
  group_by(key,value) %>% 
  summarize(count=n()) %>% 
  ungroup()

#Rename values
init.dat.prof.count$key[init.dat.prof.count$key=="Professional.Development.Other"]<-"Other"
init.dat.prof.count$key[init.dat.prof.count$key=="Opportunity.to.learn.from.other.perspective"]<-"Opportunities to learn from other perspectives"
init.dat.prof.count$key[init.dat.prof.count$key=="Learn.from.US.experience.with.hydropower"]<-"Learn from US experience with hydropower"
init.dat.prof.count$key[init.dat.prof.count$key=="Information.about.dams"]<-"Access to information about Amazon dams"
init.dat.prof.count$key[init.dat.prof.count$key=="Engage.with.other.researchers.internationally"]<-"Engage with other researchers nationally and internationally"
init.dat.prof.count$key[init.dat.prof.count$key=="Community.of.practice"]<-"Community of practice"
init.dat.prof.count$key[init.dat.prof.count$key=="Access.to.funding.opportunities"]<-"Access to research and funding opportunities"

#Change values from character to factor
init.dat.prof.count$key<-as.factor(init.dat.prof.count$key)

#init.dat.prof.count<-init.dat.prof.count %>% 
  #mutate(key = fct_relevel(key, "Other","Opportunities to learn from other perspectives",
                           #"Learn from US experience with hydropower",
                           #"Engage with other researchers nationally and internationally",
                           #"Community of practice", "Access to research and funding opportunities",
                           #"Access to information about Amazon dams"))

#Plot data
ggplot(init.dat.prof.count,aes(y=count, x=key, fill=value))+
  geom_bar(position="fill",stat="identity")+
  geom_text(aes(label=count), position=position_fill(vjust=0.5),color="white")+
  scale_fill_manual(values=c("#FDE725FF","#55C667FF","#238A8DFF","#404788FF","#440154FF"))+
  coord_flip()+
  theme_classic()+
  labs(x="",y="")+
  theme(axis.text.x =element_blank(),
        axis.ticks.x=element_blank(),
        legend.title=element_blank(),
        axis.text.y=element_text(size=12))


#Wide to long format
init.dat.boxplot <- init.dat.unique %>% 
  select(Learning.modules, Webinar.series, Research.proposals, Peer.reviewed.publications, 
         Conference.and.Symposia.planning.and.organization, Non.academic.materials.for.local.communities,
         Workshop.development.and.implementation, Technical.reports) %>% 
  gather()

#Plot data
ggplot(init.dat.boxplot, aes(x=key, y=value, fill=key))+
  geom_boxplot()+
  scale_fill_viridis_d(labels=c("Conference and symposia planning and organization",
                                "Learning modules",
                                "Non-academic materials for local communities",
                                "Peer-reviewed publications",
                                "Research proposals",
                                "Technical reports",
                                "Webinar series",
                                "Workshop development and implementation"))+
  labs(x="ADN products", y="Ranking")+
  theme_classic()+
  theme(axis.text.x=element_blank(),
        axis.ticks.x =element_blank(), 
        legend.title=element_blank())

#Split multiple answers into different rows
init.dat.collab <- init.dat.unique %>% 
  select(Collaboriation.Groups) %>% 
  mutate(Collaboriation.Groups=strsplit(as.character(Collaboriation.Groups),",")) %>% 
  unnest(Collaboriation.Groups)

#Clean up answers
init.dat.collab$Collaboriation.Groups[init.dat.collab$Collaboriation.Groups==" anglers"]<-""
init.dat.collab$Collaboriation.Groups[init.dat.collab$Collaboriation.Groups==" etc)"]<-""
init.dat.collab$Collaboriation.Groups[init.dat.collab$Collaboriation.Groups==" hunters"]<-"" 
init.dat.collab$Collaboriation.Groups[init.dat.collab$Collaboriation.Groups==" hunters etc.)"]<-""
init.dat.collab$Collaboriation.Groups[init.dat.collab$Collaboriation.Groups=="Rural workersÃ¢â‚¬â„¢ unions"]<-"Rural workers' unions"
init.dat.collab$Collaboriation.Groups[init.dat.collab$Collaboriation.Groups=="Resource recreation user groups (boaters"]<-"Resource recreation user groups (boaters, anglers, hunters, etc.)"
init.dat.collab$Collaboriation.Groups[init.dat.collab$Collaboriation.Groups=="Direct contact with community inhabitatnts"]<-"Direct contact with community inhabitants"
init.dat.collab$Collaboriation.Groups[init.dat.collab$Collaboriation.Groups=="Other (please add in the text box"]<-"Other"

#Change to factor
init.dat.collab$Collaboriation.Groups<-as.factor(init.dat.collab$Collaboriation.Groups)
#Ignore rows with no data
init.dat.collab<-filter(init.dat.collab,Collaboriation.Groups!="")
#Plot data
ggplot(init.dat.collab, aes(x=Collaboriation.Groups, fill=Collaboriation.Groups))+
  geom_bar()+
  stat_count(aes(y=..count.., label=..count..), geom="text", vjust=-.5)+
  scale_fill_viridis_d()+
  labs(x="Dam-related research and collaboration", y="Total")+
  theme_classic()+
  theme(axis.text.x=element_blank(),
        axis.ticks.x =element_blank(), 
        legend.title=element_blank())

#Filter out no data
init.dat.own <- filter(init.dat.unique, More.Productive.Working.on.my.Own != "")
#Change to character
init.dat.own$More.Productive.Working.on.my.Own <- as.character(init.dat.own$More.Productive.Working.on.my.Own)
#Reorder levels
init.dat.own$More.Productive.Working.on.my.Own <- factor(init.dat.own$More.Productive.Working.on.my.Own, levels=c("Strongly Disagree","Somewhat Disagree",
                                                                                                                                "Neither Agree nor Disagree","Somewhat Agree",
                                                                                                                                "Strongly Agree"))
#Plot data
ggplot(init.dat.own, aes(x=More.Productive.Working.on.my.Own, fill=More.Productive.Working.on.my.Own))+
  geom_bar()+
  scale_fill_manual(values=c("#440154FF","#404788FF","#238A8DFF","#55C667FF"))+
  stat_count(aes(y=..count.., label=..count..), geom="text", vjust=-.5)+
  labs(x="I tend to be more productive working on my own",y="Total")+
  theme_classic()+
    theme(axis.text.x=element_blank(),
          axis.ticks.x =element_blank(), 
          legend.title=element_blank())

#Filter out no data
init.dat.no.collab <- filter(init.dat.unique, Research.doesn.t.need.collaboration.from.other.disciplines != "")
#Reorder factors
init.dat.no.collab$Research.doesn.t.need.collaboration.from.other.disciplines <- as.character(init.dat.no.collab$Research.doesn.t.need.collaboration.from.other.disciplines)
init.dat.no.collab$Research.doesn.t.need.collaboration.from.other.disciplines <- factor(init.dat.no.collab$Research.doesn.t.need.collaboration.from.other.disciplines, levels=c("Strongly Disagree","Somewhat Disagree",
                                                                                                                  "Neither Agree nor Disagree","Somewhat Agree",
                                                                                                                  "Strongly Agree"))
#Plot data
ggplot(init.dat.no.collab, aes(x=Research.doesn.t.need.collaboration.from.other.disciplines, fill=Research.doesn.t.need.collaboration.from.other.disciplines))+
  geom_bar()+
  scale_fill_manual(values=c("#440154FF","#404788FF","#238A8DFF","#55C667FF","#FDE725FF"))+
  stat_count(aes(y=..count.., label=..count..), geom="text", vjust=-.5)+
  labs(x="My research does not generally warrant collaboration from other disciplines",y="Total")+
  theme_classic()+
  theme(axis.text.x=element_blank(),
        axis.ticks.x =element_blank(), 
        legend.title=element_blank())

#Filter no data
init.dat.methods <- filter(init.dat.unique, Integrate.methods.from.other.disciplines != "")
#Reorder levels
init.dat.methods$Integrate.methods.from.other.disciplines <- as.character(init.dat.methods$Integrate.methods.from.other.disciplines)
init.dat.methods$Integrate.methods.from.other.disciplines <- factor(init.dat.methods$Integrate.methods.from.other.disciplines, levels=c("Strongly Disagree","Somewhat Disagree",
                                                                                                                                                                                "Neither Agree nor Disagree","Somewhat Agree",
                                                                                                                                                                                "Strongly Agree"))
#Plot data
ggplot(init.dat.methods, aes(x=Integrate.methods.from.other.disciplines, fill=Integrate.methods.from.other.disciplines))+
  geom_bar()+
  stat_count(aes(y=..count.., label=..count..), geom="text", vjust=-.5)+
  scale_fill_manual(values=c("#404788FF","#238A8DFF","#55C667FF","#FDE725FF"))+
  labs(x="I integrate research methods from other disciplines", y="Total")+
  theme_classic()+
  theme(axis.text.x=element_blank(),
        axis.ticks.x =element_blank(), 
        legend.title=element_blank())

#Filter no data
init.dat.theories <- filter(init.dat.unique, Integrate.theories.and.models.from.other.disciplines != "")
#Reorder levels
init.dat.theories$Integrate.theories.and.models.from.other.disciplines <- as.character(init.dat.theories$Integrate.theories.and.models.from.other.disciplines)
init.dat.theories$Integrate.theories.and.models.from.other.disciplines <- factor(init.dat.theories$Integrate.theories.and.models.from.other.disciplines, levels=c("Strongly Disagree","Somewhat Disagree",
                                                                                                                                        "Neither Agree nor Disagree","Somewhat Agree",
                                                                                                                                        "Strongly Agree"))
#Plot data
ggplot(init.dat.theories, aes(x=Integrate.theories.and.models.from.other.disciplines, fill=Integrate.theories.and.models.from.other.disciplines))+
  geom_bar()+
  stat_count(aes(y=..count.., label=..count..), geom="text", vjust=-.5)+
  scale_fill_manual(values=c("#404788FF","#238A8DFF","#55C667FF","#FDE725FF"))+
  labs(x="I integrate theories and models from other disciplines", y="Total")+
  theme_classic()+
  theme(axis.text.x=element_blank(),
        axis.ticks.x =element_blank(), 
        legend.title=element_blank())

#Filter no data
init.dat.mult <- filter(init.dat.unique, Engaged.in.Multidisciplinary!="")

#Plot data
ggplot(init.dat.mult, aes(x=Engaged.in.Multidisciplinary))+
  geom_bar(width=0.25)+
  stat_count(aes(y=..count.., label=..count..), geom="text", vjust=-.5)+
  labs(x="Engaged in multidisciplinary work", y="Total")+
  theme_classic()+
  theme(aspect.ratio=2/1)

#Filter no data
init.dat.int <- filter(init.dat.unique, Engaged.in.interdisciplinary != "")

#Plot data
ggplot(init.dat.int, aes(x=Engaged.in.interdisciplinary))+
  geom_bar(width=0.25)+
  stat_count(aes(y=..count..,label=..count..), geom="text", vjust=-.5)+
  labs(x="Engaged in interdisciplinary work", y="Total")+
  theme_classic()+
  theme(aspect.ratio=2/1)

#Filter no data
init.dat.trans<-filter(init.dat.unique, Engaged.in.transdisciplinary != "")

#Plot data
ggplot(init.dat.trans, aes(x=Engaged.in.transdisciplinary))+
  geom_bar(width=0.25)+
  stat_count(aes(y=..count..,label=..count..), geom="text", vjust=-.5)+
  labs(x="Engaged in transdisciplinary work", y="Total")+
  theme_classic()+
  theme(aspect.ratio = 2/1)

#Change from wide to long format
expectations <- init.dat.unique %>% 
  select(Establishing.clear.expectations,Recognizing.individuals.have.different.roles,
         Identifying.roles.of.collaborators,Written.understanding.of.roles, Establishing.good.communication,
         Power.differences,Trusting.relationships,Conflict.resolution.mechanisms,Overcome.language.barriers,
         Data.protocols,Overcome.disciplinary.barriers) %>% 
  gather()

#Plot data
ggplot(expectations, aes(x=key, y=value,fill=key))+
  geom_boxplot()+
  scale_fill_viridis_d(labels=c("Establishing conflict resolution mechanisms", 
                                "Establishing protocols to share and use data",
                                "Establishing clear expectations from the beginning",
                                "Establishing good communication",
                                "Identifying the roles of research collaborators",
                                "Establishing mechanisms to overcome the barriers of understanding between disiplinary areas",
                                "Establishing mechanisms to overcome language barriers",
                                "Recognizing and accounting for power differences between participants",
                                "Recognizing individuals have specific and different roles",
                                "Establishing trusting relationships among participants",
                                "Developing a written understanding of roles and responsibilities"))+
  theme_classic()+
  theme(axis.title.x=element_blank(),
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(),
        axis.title.y=element_blank(),
        legend.title=element_blank())


##Plotting ADN connections

par(mfrow=c(1,1))

######################
##Dam collaborations##
######################

#Read an adjacency matrix (R stores it as a data frame by default)
relations <- read.csv("./Data/ADNPalmasDamCollabOnDams.csv",header=T,stringsAsFactors=FALSE)
row.names(relations)<-relations[,1]
relations <- relations[,2:62]

#Here's a case where matrix format is preferred
relations <- as.matrix(relations) # convert to matrix format
relations <- ifelse(relations == "Collaborated With On Dam-related Activities", 1,0)

#Read in some vertex attribute data (okay to leave it as a data frame)
nodeInfo <- read.csv("./Data/ADNPalmasAtts.csv",header=TRUE,stringsAsFactors=FALSE)
nodeInfo

nrelations<-network(relations,directed=TRUE) # Create a network object based on relations
nrelations # Get a quick description of the data

summary(nrelations) # Get an overall summary
network.dyadcount(nrelations) # How many dyads in nflo?
network.edgecount(nrelations) # How many edges are present?
network.size(nrelations) # How large is the network?
as.sociomatrix(nrelations) # Show it as a sociomatrix
nrelations[,] # Another way to do it

plot(nrelations,displaylabels=F,jitter=F,usearrows=T,displayisolates=T,vertex.col="blue",edge.col="darkgray",main="Collaborated with on dam-realted topics") # Plot with names

##############################
##Dam-related communications##
##############################

dam.comm <- read.csv("./Data/ADNPalmasCommDam.csv",header=T,stringsAsFactors=FALSE)
row.names(dam.comm)<-dam.comm[,1]
dam.comm <- dam.comm[,2:62]

#Here's a case where matrix format is preferred
dam.comm <- as.matrix(dam.comm) # convert to matrix format
dam.comm   <- ifelse(dam.comm == "Communicated With On Dam-related Topics", 1,0)
dam.comm[is.na(dam.comm)]<-0

nrelations<-network(dam.comm,directed=TRUE) # Create a network object based on relations
nrelations # Get a quick description of the data

summary(nrelations) # Get an overall summary
network.dyadcount(nrelations) # How many dyads in nflo?
network.edgecount(nrelations) # How many edges are present?
network.size(nrelations) # How large is the network?
as.sociomatrix(nrelations) # Show it as a sociomatrix
nrelations[,] # Another way to do it

plot(nrelations,displaylabels=F,jitter=F,usearrows=T,displayisolates=T,vertex.col="blue",edge.col="darkgray",main="Communicated with on dam-related topics") # Plot with names


##########################
##Non-dam collaborations##
##########################
nondam.coll <- read.csv("./Data/ADNPalmasCollabNonDam.csv",header=T,stringsAsFactors=FALSE)
row.names(nondam.coll)<-nondam.coll[,1]
nondam.coll <- nondam.coll[,2:62]

#Here's a case where matrix format is preferred
nondam.coll <- as.matrix(nondam.coll) # convert to matrix format
nondam.coll <- ifelse(nondam.coll == "Collaborated with on non-dam related activities", 1,0)

nrelations<-network(nondam.coll,directed=TRUE) # Create a network object based on relations
nrelations # Get a quick description of the data

summary(nrelations) # Get an overall summary
network.dyadcount(nrelations) # How many dyads in nflo?
network.edgecount(nrelations) # How many edges are present?
network.size(nrelations) # How large is the network?
as.sociomatrix(nrelations) # Show it as a sociomatrix
nrelations[,] # Another way to do it

plot(nrelations,displaylabels=F,jitter=F,usearrows=T,displayisolates=T,vertex.col="blue",edge.col="darkgray",main="Collaborated with on non-dam topics") # Plot with names

##########################
##Non-dam Communications##
##########################
#Read an adjacency matrix (R stores it as a data frame by default)
nondam.comm <- read.csv("./Data/ADNPalmasCommNonDam.csv",header=T,stringsAsFactors=FALSE)
row.names(nondam.comm)<-nondam.comm[,1]
nondam.comm <- nondam.comm[,2:62]

#Here's a case where matrix format is preferred
nondam.comm <- as.matrix(nondam.comm) # convert to matrix format
nondam.comm <- ifelse(nondam.comm == "Communicated with on non-dam related topics", 1,0)

###########################################################
##3.2 Creating network objects, working with edgelists

nrelations<-network(nondam.comm,directed=TRUE) # Create a network object based on relations
nrelations # Get a quick description of the data

summary(nrelations) # Get an overall summary
network.dyadcount(nrelations) # How many dyads in nflo?
network.edgecount(nrelations) # How many edges are present?
network.size(nrelations) # How large is the network?
as.sociomatrix(nrelations) # Show it as a sociomatrix
nrelations[,] # Another way to do it

plot(nrelations,displaylabels=F,jitter=F,usearrows=T,displayisolates=T,vertex.col="blue",edge.col="darkgray",main="Communicated with on non-dam topics") # Plot with names

