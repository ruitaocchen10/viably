# Viably Project Documentation

3.9.2026

10:22 AM -
I set a goal today to see if I can build a mobile app in 1 day, having never built/shipped an iOS to the app store. I haven’t used Swift a lot, and I’m going to see if I can use Claude Code and knowledge of systems and UX to build something available for commercial use by the end of the day.

    I’ve decided a couple of things already:

1. App Basics - Gamified app to build habits, using social features as well to build accountability (a bit like Strava for life habits?)
   1. Feature 1 - Gamification:
      1. Streaks, XP, something along those lines to create dopamine hits after completing habits?
   2. Feature 2 - Minimum Viable Day:
      1. Allow users to create a minimum viable day for easy completions and momentum building
   3. Feature 3 - Post creation:
      1. Ability to share days to your friends and encourage/hold each other accountable for habit building
2. Tech stack
   1. Swift
      1. Sorry I use Apple products and I can’t be bothered to cater to inferior Android users
   2. Supabase
      1. Considering I’m building this in one day I don’t have the confidence to try a different backend/database service

10:37 AM -
As a product guy, I tend to build better if I can see something with my eyes. Because of that, I want to experiement with the Figma MCP today, to see if maybe I can speed up more workflow or improve my output.

12:16 PM -

    I spent about 2 hours coming up with a theme and basic UI layout of the home screen in Figma, which, in hindsight, probably was not the best use of my time. I really gotta start building now; I’m going to just build some momentum by building a nice authentication flow and screen with Supabase’s built in service. 	Auth seems to be pretty easy to implement; I’m using the supabase swift kit and I can pretty much just one-shot the auth flow using the theme Claude Code got from my Figma MCP. I’ll probably make some minor changes but don’t anticipate much issues with this.

    Alright, Auth ended up being much more complicated than I expected… took a lot of fixing and shifting to vibe code it. I’ve started with just enabling Google OAuth in my app:

- AuthView: Main Auth screen that you see when you open the app, only with a sign-in with Google button right now
- AuthViewModel: Listens to Supabase’s authStateChanges to figure out if the user is authenticated or not

  3.10.2026

4:48 PM -

    Okay, I’m absolutely not finishing this in a day

    I’m going to start out with building the structure of this app, with my 4 main views (which I decided through my Figma designs). These views will be the HomeView (viewing calendar, daily habits, and progress), SocialView (viewing other people’s posts), CreationView (to create and manage habits), and ProfileView (for viewing your profile).

    I’m getting familiar with the View, ViewModel, Service, Model

    Figma MCP servers are hitting rate limits, ugh. Might have to go with pure screenshot reading.

3.11.2026

9:38 AM -
Potential general plan:1. Auth + Profile — Everything else gates on a logged-in user with a user_id. Build this first so all subsequent work has a real
authenticated context to test against. 2. Habits (vertical slice) — Model → Service (CRUD against Supabase) → ViewModel → View. This is your core loop. Get create,
list, and delete working end-to-end. 3. Habit Completions + Streaks — Builds directly on habits. Complete a habit, see the streak increment. This is the primary
emotional hook — validate it early. 4. Daily Score + MVD — Depends on completions existing. The score bar and viable day indicator live here. 5. Posts + Friend Feed — Depends on daily scores existing. Social layer comes last since it requires the core habit loop to
already feel good. 6. Friendships + Hypes — The social graph and reactions; lowest priority for MVP feel.

- Starting by building out Auth and profile from Model all the way to View. First step is to create a Model folder and file for the profile Model.
- Adding RLS to Profiles Table in Supabase for security so that authenticated users can only access their row
- Build Profile View Model with loadProfile and save functions, which loads profile data and saves profile data changes respectively
- Creating ProfileView UI and Components! The fun part! Had to download fonts, and fix grants in Supabase.
- Be careful with your rm commands kids… my dumbass really deleted my entire project again… luckily this time I had a more recent commit to revert to
- Had to create CodingKeys (JSON <-> Swift) to convert camel case into the right Supabase data text

2:19 PM

- ListenToAuthChanges wasn’t accounting for initial session, so every session was taking you to auth page no matter what
- Did a lot of UI tweaking, profile screen is definitely looking better but there’s still some functionality, not to mention I’m incredibly behind on everything else
- Starting on some of the HomeView elements, introducing Habit tables, Habit Completion tables, and Daily Score tables
- Created services to fetch and create habits, update streaks
- Fetch completions and a singular completion, complete and uncomplete
- Fetch the date for daily scores and update the score
- Split UI into HomeView:
  - Components:
    - Calendar, Daily Score, Habits

6:05 PM

- Build out MyHabitsView and CreateHabit functionality
- We should have a lot of what we need already, because the Models and Services for Habit should mainly apply to these Views as well.
- Had to add descriptions to the habit model
- MyHabitsViewModel includes methods for loading and creating Habits

9:19 AM

- For the main features in HomeView and MyHabits view, the everything from ViewModel down is pretty much built out. From here, it’s mostly about fine-tuning the UI.

5:30 PM

- I spent a really long time fine-tuning the UI and honestly I’m still not entirely happy with it, but it’s definitely close to being good. Most of the functionality in terms of just creating and reading habits is working, although i’m yet to see about certain bugs that might exist (which will reveal itself with more testing).
- I’m running a couple of debugging agents right now, which I’ll essentially have return issues one-by-one and then I’ll go through them one-by-one and see if it’s something actually worth fixing.

9:32 AM

- I actually experimented with kind of one-shotting the Social Elements… although i did update the plan about 20 times before i actually pushed it through. To be honest, it was just one of those things where I wanted to see what would happen if I tried it. A couple reasons I wanted to give this a shot was:
  - I had everything committed up to that point so it would’ve been easy to revert, although i probably would’ve wasted half my token limit at the same time
  - There was consistency already in how my app was built at that point so i wanted to see if the agent could use the context of the already existing code to build another feature in a way that would integrate well with my codebase
- I’m still examining to see how it did, but I will say so far it’s looking pretty good.
- I had to build on top of it, but honestly it did amazing.
- Things still needed to change: - HomeView - Share day button? - Your Habits order in which they display - SocialView - Search by username button gets a little smaller when you click on it (done) - MyHabits - HabitRows look weird on top of each other - fix (done) - ProfileView - Signout button - Add one more element - Github view or weekly visual?

  3.17.2026

Debugging Profile Photos

- The avatar display in the app has been pretty buggy and after examining the app a little, there are 5 different logics on how the avatar is displayed. Overall, it's messy, confusing, and for a component that's going to show up several times in different parts of the app we should really shore up the fetching and displaying logic.
- I should be able to create a single component that can display the avatar based on the URL that's passed through depending on the page it's on. This should be a cleaner solution that gives consistency in the way the avatar looks and is loaded in every page.
- Note: when a profile is updated, the view will only show that update when the information is reloaded. For example, on the HomeView profile information is only loaded when opening the app for the first time, so that will only change when you exit the app and come back... for now.

  3.18.2026

Debugging Habits -
