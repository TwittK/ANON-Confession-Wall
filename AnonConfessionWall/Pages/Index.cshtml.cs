using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace AnonConfessionWall.Pages;

public class IndexModel : PageModel
{
    public List<ConfessionPost> TrendingPosts { get; set; } = new();
    public List<ConfessionPost> FeedbackPosts { get; set; } = new();
    public List<ConfessionPost> HealthPosts { get; set; } = new();
    [BindProperty]
    public PostModel NewPost { get; set; } = new();
    public void OnGet()
    {
        // This would be fetched from a database in a real app
        var allPosts = new List<ConfessionPost>
        {
            new() { Id = 1, Category = "Health", Content = "Feeling mentally drained lately...", Upvotes = 12, PostedAt = DateTime.Now.AddMinutes(-5) },
            new() { Id = 2, Category = "Feedback", Content = "Library closes too early...", Upvotes = 9, PostedAt = DateTime.Now.AddHours(-1) },
            new() { Id = 3, Category = "Health", Content = "Burnout creeping in", Upvotes = 20, PostedAt = DateTime.Now.AddMinutes(-30) },
        };

        TrendingPosts = allPosts.OrderByDescending(p => p.Upvotes).ToList();
        FeedbackPosts = allPosts.Where(p => p.Category == "Feedback").ToList();
        HealthPosts = allPosts.Where(p => p.Category == "Health").ToList();
    }
    public IActionResult OnPostCreate()
    {
        if (!ModelState.IsValid)
        {
            // Repopulate data if form fails
            OnGet();
            return Page();
        }

        // TODO: Save to DB later – for now simulate post
        var newConfession = new ConfessionPost
        {
            Id = new Random().Next(100, 999), // Simulated ID
            Category = NewPost.Category,
            Content = NewPost.Content,
            Upvotes = 0,
            PostedAt = DateTime.Now
        };

        // Temporarily simulate saving by adding to Trending
        TrendingPosts.Add(newConfession);
        if (newConfession.Category == "Feedback") FeedbackPosts.Add(newConfession);
        if (newConfession.Category == "Health") HealthPosts.Add(newConfession);

        // Clear the form
        NewPost = new();

        // Stay on same page
        return RedirectToPage();
    }

}




public class ConfessionPost
{
    public int Id { get; set; }
    public string Category { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public int Upvotes { get; set; }
    public DateTime PostedAt { get; set; }
}

public class PostModel
{
    public string Category { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    public DateTime PostedAt { get; set; }
}

