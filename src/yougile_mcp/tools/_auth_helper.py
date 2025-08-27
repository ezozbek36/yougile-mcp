"""
Helper for authentication in MCP tools.
Ensures authentication is initialized for each tool call.
"""

from mcp.server.fastmcp import Context
from ...core import auth


async def ensure_authenticated(ctx: Context) -> None:
    """Ensure authentication is initialized for YouGile API access."""
    if not auth.auth_manager.is_authenticated():
        from ...server import initialize_auth
        success = await initialize_auth()
        if not success:
            raise Exception("Failed to initialize YouGile authentication. Check credentials.")